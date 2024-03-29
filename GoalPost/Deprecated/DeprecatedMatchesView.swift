//
//  Main Screen View.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

// Collectionview documentation - https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views

import Foundation
import UIKit
import GoogleMobileAds

class DeprecatedMatchesView: UIView {
    
    // MARK: Views
    
    var mainStack = CustomStack(.vertical)
    
    var dateArea = UIStackView(.horizontal)
    var collectionArea = UIView()
    var buttonArea = UIView()
    
    var collectionView: UICollectionView!
    
    // MARK: Buttons
    
    var nextDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(nextDay), for: .touchUpInside)
        return button
    } ()
    
    var previousDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(previousDay), for: .touchUpInside)
        return button
    } ()
    
    // MARK: Labels
    
    var dateLabel = UILabel()
    
    // MARK: Data
    
    var currentDate = Date()
    
    var dataSource: UICollectionViewDiffableDataSource<MatchesSectionDataContainer, MatchesCellType>!
    
    // MARK: Gestures
    
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    var refreshControl: UIRefreshControl!
    
    init() {
        super.init(frame: CGRect.zero)
        
        testing()
        
        setUpUI()
        setUpCollectionView()
        setUpDataSourceSnapshots(from: Date.now)
        setUpColors()
        setUpGestures()
    }
    
    func testing() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    // 1
    func setUpUI() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(dateArea, 0.075), (collectionArea, 0.9)])
        
        // Date
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textAlignment = .center
        dateArea.add(children: [(previousDayButton, 0.2), (dateLabel, 0.6), (nextDayButton, nil)])
    }
    
    // 2
    func setUpCollectionView() {
        // MARK: Create list layout
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.headerTopPadding = 0
        layoutConfig.backgroundColor = Colors.backgroundColor
        layoutConfig.showsSeparators = true
        layoutConfig.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        // MARK: Configure Collection View
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: listLayout)
        collectionArea.constrain(collectionView)
        
        // MARK: Cell registration
        let leagueCellRegistration = UICollectionView.CellRegistration<LeagueCell, LeagueObject>(handler: {
            (cell, indexPath, league) in
            
            cell.league = league
            
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header, isHidden: false, reservedLayoutWidth: .custom(0.001), tintColor: Colors.headerTextColor)
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
        })
        
        let matchCellRegistration = UICollectionView.CellRegistration<MatchesCell, MatchObject>(handler: {
            (cell, indexPath, match) in
            
            cell.match = match
        })
        
        let adCellRegistration = UICollectionView.CellRegistration<AdCell, AdObject>(handler: {
            (cell, indexPath, ad) in
            
            cell.ad = ad
        })
        
        // MARK: Initialize data source
        dataSource = UICollectionViewDiffableDataSource<MatchesSectionDataContainer, MatchesCellType>(collectionView: collectionView) {
            (collectionView, indexPath, cellType) -> UICollectionViewCell? in
            
            switch cellType {
            case .league(let league):
                
                let cell = collectionView.dequeueConfiguredReusableCell(using: leagueCellRegistration, for: indexPath, item: league)
                return cell
                
            case .match(let match):
                
                let cell = collectionView.dequeueConfiguredReusableCell(using: matchCellRegistration, for: indexPath, item: match)
                return cell
                
            case .ad(let ad):
                
                let cell = collectionView.dequeueConfiguredReusableCell(using: adCellRegistration, for: indexPath, item: ad)
                return cell
            }
        }
        
        // MARK: Set Up Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshWithCurrentData), for: .valueChanged)
        collectionView!.addSubview(refreshControl)
    }
    // 3
    func setUpDataSourceSnapshots(from date: Date) {
        // MARK: Setup snap shots
        
        Task.init {
            
            // Create new datasource snapshot
            var dataSourceSnapshot = NSDiffableDataSourceSnapshot<MatchesSectionDataContainer, MatchesCellType>()
            
            // Get only the matches for the current date
            let matchesByDay = QuickCache.helper.matchesByDateDictionary[date.asKey] ?? Set<MatchUniqueID>()
            
            var leagueMatchDictionary = [LeagueID:Set<MatchUniqueID>]()
            var leagueDataContainers = [MatchesSectionDataContainer]()
            
            // For each league
            for leagueId in QuickCache.helper.favoriteLeaguesDictionary.keys {
                // Get all of the matches for the league
                guard let leagueSet = await Cached.data.matchesByLeagueDictionary[leagueId], let league = await Cached.data.leagueDictionary[leagueId] else {
                    continue
                }
                
                // Find which matches are also being played today. If there are any, add them to leagueMatchDictionary
                let intersectingSet = matchesByDay.intersection(leagueSet)
                leagueMatchDictionary[leagueId] = intersectingSet
                
                // If there are matches being played today, create a new League object and add it to leagueDataContainers
                if !intersectingSet.isEmpty {
                    let leagueDataContainer = MatchesSectionDataContainer(.league(league))
                    leagueDataContainers.append(leagueDataContainer)
                }
            }
            
            // Create a special league object (for myteams) and add it to leagueDataContainers
            let myTeams = LeagueObject(id: DefaultIdentifier.favoriteTeam.rawValue, name: "My Teams", country: "NA")
            let leaguesList = [MatchesSectionDataContainer(.league(myTeams))] + leagueDataContainers
            
            
            // Get all favorite matches by iterating over each favorite team
            let matchesByTeamDictionary = QuickCache.helper.matchesByTeamDictionary
            var allFavoriteMatches: Set<MatchUniqueID> = []
            for team in QuickCache.helper.favoriteTeamsDictionary {
                if let newSet = matchesByTeamDictionary[team.key] {
                    allFavoriteMatches = allFavoriteMatches.union(newSet)
                } else {
                    print("MatchesView - Cound not find matches for team \(team.key)")
                }
            }
            
            // Add only the favorite matches being played today to the leagueMatchDictionary
            leagueMatchDictionary[DefaultIdentifier.favoriteTeam.rawValue] =  matchesByDay.intersection(allFavoriteMatches)
            
            // Insert advertising sections
            
            if leagueDataContainers.isEmpty {
                leagueDataContainers.append(MatchesSectionDataContainer(.ad(AdObject(adViewName: .matchAd1))))
            } else {
                leagueDataContainers.insert(MatchesSectionDataContainer(.ad(AdObject(adViewName: .matchAd1))), at: 1)
                
                if leagueDataContainers.count > 4 {
                    leagueDataContainers.insert(MatchesSectionDataContainer(.ad(AdObject(adViewName: .matchAd2))), at: 4)
                }
                
                if leagueDataContainers.count > 6 {
                    leagueDataContainers.insert(MatchesSectionDataContainer(.ad(AdObject(adViewName: .matchAd3))), at: 5)
                }
                
                if leagueDataContainers.count > 8 {
                    leagueDataContainers.insert(MatchesSectionDataContainer(.ad(AdObject(adViewName: .matchAd4))), at: 7)
                }
                
                if leagueDataContainers.count > 10 {
                    leagueDataContainers.insert(MatchesSectionDataContainer(.ad(AdObject(adViewName: .matchAd5))), at: 9)
                }
            }
            
            
            // Add the sections (the league objects) to the snapshot
            dataSourceSnapshot.appendSections(leaguesList)
            await dataSource.apply(dataSourceSnapshot)
            
            // Go through each item in the list, which will either be an ad or a league
            for sectionItem in leaguesList {
                
                // Create new section
                var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<MatchesCellType>()
                
                switch sectionItem.sectionType {
                case .league(let league):
                    
                    // If the item is a league, append a "MatchesCellType" enum to it (this contains info about the league)
                    let leagueListItem = MatchesCellType.league(league)
                    sectionSnapshot.append([leagueListItem])
                    
                    // Get the matchIDs that correspond to this league
                    guard let matchSet = leagueMatchDictionary[league.id] else {
                        print("MatchesView - No matches found for league \(league.name)")
                        continue }
                    
                    // Go through each matchID and get the match object associated with it from the matchesDictionary
                    let matchesDictionary = await Cached.data.matchesDictionary
                    var matchObjects = [MatchObject]()
                    matchObjects = matchSet.compactMap { matchesDictionary[$0] }
                    
                    // Sort the match objects by timestamp and then alphabetically. Once sorted create a new "MatcheCellType" enum for type match (which includes info about the match)
                    let matchCells = matchObjects.sorted(by: {
                        if $0.timeStamp < $1.timeStamp {
                            return true
                        } else if $0.timeStamp == $1.timeStamp {
                            return $0.homeTeamId < $1.homeTeamId
                        } else {
                            return false
                        } }).map { MatchesCellType.match($0) }
                    
                    // Add the cells just created to the league, and then expand it
                    sectionSnapshot.append(matchCells, to: leagueListItem)
                    sectionSnapshot.expand([leagueListItem])
                    await dataSource.apply(sectionSnapshot, to: sectionItem, animatingDifferences: true)
                case .ad(let adData):
                    let adItem = MatchesCellType.ad(adData)
                    sectionSnapshot.append([adItem])
                    await dataSource.apply(sectionSnapshot, to: sectionItem, animatingDifferences: true)
                case .match(_):
                    return
                }
            }
        }
    }
    
    // 4
    // NOTE: CollectionView backgroundColor is set up by changing the layout color in setUpCollectionView
    func setUpColors() {
        
        // Buttons
        nextDayButton.tintColor = Colors.titleAreaTextColor
        previousDayButton.tintColor = Colors.titleAreaTextColor
        
        // Labels
        dateLabel.textColor = Colors.titleAreaTextColor
        
        // Backgrounds
        dateArea.backgroundColor = Colors.titleAreaColor
    }
    
    // 5
    func setUpGestures() {
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextDay))
        addGestureRecognizer(swipeLeft)
        swipeLeft.delegate = self
        swipeLeft.direction = .left
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(previousDay))
        addGestureRecognizer(swipeRight)
        swipeRight.delegate = self
        swipeRight.direction = .right
    }
    
    
    func clearCells() {
        
        // Create new datasource snapshot
        let dataSourceSnapshot = NSDiffableDataSourceSnapshot<MatchesSectionDataContainer, MatchesCellType>()
        dataSource.apply(dataSourceSnapshot, animatingDifferences: true)
    }
    
    //NOTE: Configuration of cell body: https://swiftsenpai.com/development/uicollectionview-list-custom-cell/
}

extension DeprecatedMatchesView: UICollectionViewDelegate {
    
}

//MARK: Button Actions
extension DeprecatedMatchesView {
    
    @objc func nextDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = getNextDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        clearCells()
        refresh()
        
    }
    
    @objc func previousDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = getPreviousDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        clearCells()
        refresh()
    }
    
    @objc func refreshWithCurrentData() {
        DataFetcher.helper.getMatchesForCurrentDay() {
            DispatchQueue.main.async {
                print("Activating completion")
                self.refresh()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func getNextDay(from date: Date) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = 1
        
        let newDate = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
        return newDate
    }
    
    private func getPreviousDay(from date: Date) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = -1
        
        let newDate = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
        return newDate
    }
}

// MARK: Changes

extension DeprecatedMatchesView {
    func changeDate(to date: Date) {
        dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    }
}

// MARK: Protocols

extension DeprecatedMatchesView: MatchesViewDelegate {
    func refresh() {
        setUpDataSourceSnapshots(from: currentDate)
    }
}

// MARK: Extensions
extension DeprecatedMatchesView: UIGestureRecognizerDelegate {
    
}
