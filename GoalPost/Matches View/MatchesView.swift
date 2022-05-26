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

class MatchesView: UIView {
    
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
        
        setUpMainStack()
        setUpDate()
        setUpCollectionView()
        setUpColors()
        setUpGestures()
        
        MatchesDataContainer.helper.delegate = self
    }
    
    func testing() {
        //Cached.matches = [:]
        //Cached.favoriteTeamMatches = [:]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    func setUpMainStack() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(dateArea, 0.075), (collectionArea, 0.9)])
    }
    
    func setUpDate() {
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textAlignment = .center
        dateArea.add(children: [(previousDayButton, 0.2), (dateLabel, 0.6), (nextDayButton, nil)])
    }
    
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
        let leagueCellRegistration = UICollectionView.CellRegistration<LeagueCell, MatchLeagueData>(handler: {
            (cell, indexPath, league) in
            
            cell.league = league
            
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header, isHidden: false, reservedLayoutWidth: .custom(0.001), tintColor: Colors.headerTextColor)
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
        })
        
        let matchCellRegistration = UICollectionView.CellRegistration<MatchCell, MatchData>(handler: {
            (cell, indexPath, match) in
            
            cell.match = match
        })
        
        let adCellRegistration = UICollectionView.CellRegistration<AdCell, AdData>(handler: {
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
    
    func clearCells() {
        
        // Create new datasource snapshot
        let dataSourceSnapshot = NSDiffableDataSourceSnapshot<MatchesSectionDataContainer, MatchesCellType>()
        dataSource.apply(dataSourceSnapshot, animatingDifferences: true)
    }
    
    func setUpDataSourceSnapshots(from date: Date) {
        // MARK: Setup snap shots
        
        // Create new datasource snapshot
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<MatchesSectionDataContainer, MatchesCellType>()
        
        // Get only the matches for the current date
        let currentMatches = Cached.matches[date.asKey] ?? [:]
        
        // Create a list of each league for that date and sort the leagues alphabetically
        var preferredLeagues = currentMatches.map { MatchesSectionDataContainer(.league($0.value)) }.sorted { $0.name < $1.name }
        
        
        let safeWidth = Float(self.frame.inset(by: self.safeAreaInsets).width)
        
        
        if preferredLeagues.isEmpty {
            preferredLeagues.append(MatchesSectionDataContainer(.ad(AdData(adViewName: .matchAd1, viewWidth: safeWidth))))
        } else {
            preferredLeagues.insert(MatchesSectionDataContainer(.ad(AdData(adViewName: .matchAd1, viewWidth: safeWidth))), at: 1)
            
            if preferredLeagues.count > 4 {
                preferredLeagues.insert(MatchesSectionDataContainer(.ad(AdData(adViewName: .matchAd2, viewWidth: safeWidth))), at: 3)
            }
            
            if preferredLeagues.count > 6 {
                preferredLeagues.insert(MatchesSectionDataContainer(.ad(AdData(adViewName: .matchAd3, viewWidth: safeWidth))), at: 5)
            }
            
            if preferredLeagues.count > 8 {
                preferredLeagues.insert(MatchesSectionDataContainer(.ad(AdData(adViewName: .matchAd4, viewWidth: safeWidth))), at: 7)
            }
            
            if preferredLeagues.count > 10 {
                preferredLeagues.insert(MatchesSectionDataContainer(.ad(AdData(adViewName: .matchAd5, viewWidth: safeWidth))), at: 9)
            }
        }
        
        // NOTE: User Teams
        let myTeams = Cached.favoriteTeamMatches[date.asKey] ?? MatchLeagueData(name: "My Teams", country: "NA", id: FavoriteTeamLeague.identifer.rawValue, matches: [:])
        let leaguesList = [MatchesSectionDataContainer(.league(myTeams))] + preferredLeagues
        
        // Add sections to the snapshot (just adding an array)
        dataSourceSnapshot.appendSections(leaguesList)
        
        // Apply the snapshot to the datasource
        dataSource.apply(dataSourceSnapshot)
        
        // Create a section snapshot for each league
        for sectionItem in leaguesList {
            
            // Create new section snapshot
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<MatchesCellType>()
            
            // Create a new "ListItem" object, and assign the current league to it. Then append it to the snapshot
            
            switch sectionItem.sectionType {
            case .league(let league):
                let leagueListItem = MatchesCellType.league(league)
                sectionSnapshot.append([leagueListItem])
                
                // Create an array of "ListItem" objects and assign each match for a given league to it. Then append that list to its "parent"
                let matchItems = league.matches.sorted(by: {
                    if $0.value.timeStamp < $1.value.timeStamp {
                        return true
                    } else if $0.value.timeStamp == $1.value.timeStamp {
                        return $0.value.homeTeam.name < $1.value.homeTeam.name
                    } else {
                        return false
                    } }).map { MatchesCellType.match($0.value) }
                sectionSnapshot.append(matchItems, to: leagueListItem)
                
                // Expand this section by default
                sectionSnapshot.expand([leagueListItem])
                
                // Apply section snapshot to the respective collection view section
                dataSource.apply(sectionSnapshot, to: sectionItem, animatingDifferences: true)
            case .ad(let adData):
                let adItem = MatchesCellType.ad(adData)
                sectionSnapshot.append([adItem])
                dataSource.apply(sectionSnapshot, to: sectionItem, animatingDifferences: true)
            case .match(let match):
                return
            }
            
        }
    }
    
    func updateDataSourceSnapshot() {
        // MARK: Setup snap shots
        
        print("Update data source snapshot")
        
        let date = currentDate
        
        // Create new datasource snapshot
        var updatedSnapshot = dataSource.snapshot()

        for section in updatedSnapshot.sectionIdentifiers {
            //print(section.sectionType)
            switch section.sectionType {
            case .league(let league):

                var currentLeagueDictionary = Cached.matches[date.asKey] ?? [:]
                currentLeagueDictionary[FavoriteTeamLeague.identifer.rawValue] = Cached.favoriteTeamMatches[date.asKey] ?? MatchLeagueData(name: "My Teams", country: "NA", id: FavoriteTeamLeague.identifer.rawValue, matches: [:])
                
                guard let currentLeague = currentLeagueDictionary[league.id] else {
                    updatedSnapshot.deleteSections([section])
                    print("League not found")
                    continue
                }

                var currentMatches = currentLeague.matches.sorted(by: {
                    if $0.value.timeStamp < $1.value.timeStamp {
                        return true
                    } else if $0.value.timeStamp == $1.value.timeStamp {
                        return $0.value.homeTeam.name < $1.value.homeTeam.name
                    } else {
                        return false
                    } }).map { MatchesCellType.match($0.value) }
                
                var matchItems = league.matches.map { MatchesCellType.match($0.value) }
                
                print(matchItems.count, currentMatches.count)
                
                // https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/updating_collection_views_using_diffable_data_sources
                
                updatedSnapshot.deleteItems(matchItems)
                updatedSnapshot.appendItems(currentMatches, toSection: section)
                //updatedSnapshot.reconfigureItems(currentMatches)
                
                dataSource.apply(updatedSnapshot, animatingDifferences: true)
            default:
                continue
            }
        }
    }
    
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
    
    //NOTE: Configuration of cell body: https://swiftsenpai.com/development/uicollectionview-list-custom-cell/
}

extension MatchesView: UICollectionViewDelegate {
    
}

//MARK: Button Actions
extension MatchesView {
    
    @objc func nextDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = getNextDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        clearCells()
        refresh(update: false)
        
    }
    
    @objc func previousDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = getPreviousDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        clearCells()
        refresh(update: false)
    }
    
    @objc func refreshWithCurrentData() {
        MatchesDataContainer.helper.retrieveAllMatchesForCurrentDate(update: true)
        refreshControl.endRefreshing()
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

extension MatchesView {
    func changeDate(to date: Date) {
        dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    }
}

// MARK: Protocols

extension MatchesView: MatchesViewDelegate {
    func refresh(update: Bool) {
        if update {
            updateDataSourceSnapshot()
        } else {
            setUpDataSourceSnapshots(from: currentDate)
        }
    }
}

// MARK: Extensions
extension MatchesView: UIGestureRecognizerDelegate {
    
}
