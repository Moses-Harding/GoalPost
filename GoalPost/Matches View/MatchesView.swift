//
//  MatchesView 2.0.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//

import Foundation
import UIKit

/*
 DOCUMENTATION
 
 Setup
 1 - Set Up UI
 2 - Register MatchesContainerCell with the collectionView. This process triggers the construciton of a collectionViewLayout
 3 - DataSource is initialized
 4 - Set Up Colors
 5 - Set Up Gestures (accompanying next / previous day buttons)
 6 - Apply the data (find all favorite leagues and insert new ones as necessary)
 */

class MatchesView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: Views
    
    var mainStack = CustomStack(.vertical)
    
    var dateArea = UIStackView(.horizontal)
    var collectionArea = UIView()
    var buttonArea = UIView()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
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
    
    var dataSource: UICollectionViewDiffableDataSource<ObjectContainer, ObjectContainer>!
    
    // MARK: Gestures
    
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    var refreshControl: UIRefreshControl!
    
    init() {
        super.init(frame: CGRect.zero)
        
        print("MatchesView - init")
        
        setUpUI()
        setUpCollectionView()
        setUpDataSource()
        setUpColors()
        setUpGestures()
        applyData()
        
        print("MatchesView - init complete")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    // 1
    func setUpUI() {
        
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(dateArea, 0.075), (collectionArea, 0.9)])
        collectionArea.constrain(collectionView)
        
        // Date
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textAlignment = .center
        dateArea.add(children: [(previousDayButton, 0.2), (dateLabel, 0.6), (nextDayButton, nil)])
        
        // MARK: Set Up Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(updateMatches), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    // 2
    private func setUpCollectionView() {
        
        collectionView.register(LeagueHeaderCell.self, forCellWithReuseIdentifier: String(describing: LeagueHeaderCell.self))
        collectionView.register(MatchCell.self, forCellWithReuseIdentifier: String(describing: MatchCell.self))
        collectionView.delegate = self
    }
    
    // 2.5 - Called via lazy initialization of collectionview
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        let padding: CGFloat = 0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(50))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = .init(top: 20, leading: padding, bottom: padding, trailing: padding)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // 3
    private func setUpDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<ObjectContainer, ObjectContainer>(collectionView: collectionView) {
            (collectionView, indexPath, objectContainer) -> UICollectionViewCell? in
            
            switch objectContainer.type {
            case .league:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: LeagueHeaderCell.self),
                    for: indexPath) as? LeagueHeaderCell else {
                    fatalError("Could not cast cell as \(LeagueHeaderCell.self)") }
                
                cell.objectContainer = objectContainer
                return cell
            case .match:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: MatchCell.self),
                    for: indexPath) as? MatchCell else {
                    fatalError("Could not cast cell as \(MatchCell.self)") }
                
                cell.objectContainer = objectContainer
                return cell
            default:
                fatalError("Object container not valid")
            }
            
        }
        
        collectionView.dataSource = dataSource
    }
    
    // 4
    func setUpColors() {
        /// NOTE: CollectionView backgroundColor is set up by changing the layout color in setUpCollectionView
        // Buttons
        nextDayButton.tintColor = Colors.titleAreaTextColor
        previousDayButton.tintColor = Colors.titleAreaTextColor
        
        // Labels
        dateLabel.textColor = Colors.titleAreaTextColor
        
        // Backgrounds
        dateArea.backgroundColor = Colors.titleAreaColor
        
        collectionArea.backgroundColor = .yellow
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
    
    // 6
    func applyData() {
        
        guard let dataSource = dataSource else { return }
        
        // Get favorite leagues and sort
        var leagues = [ObjectContainer]()
        leagues.append(ObjectContainer(favoriteLeague: true))
        let favoriteLeagues = QuickCache.helper.favoriteLeaguesDictionary
        for (leagueID, leagueObject) in favoriteLeagues.sorted(by: {$0.value.name < $1.value.name}) {
            leagues.append(ObjectContainer(leagueId: leagueID, name: leagueObject.name))
        }
        
        // Add favorite leagues as section headers to snapshot
        var snapShot = dataSource.snapshot()
        snapShot.applyDifferences(newSections: leagues)
        dataSource.apply(snapShot)
        
        // For each league, get the relevant matches
        for league in leagues {
            
            var leagueID: LeagueID
            
            if league.favoriteLeague {
                leagueID = DefaultIdentifier.favoriteTeam.rawValue
            } else if let id = league.leagueId {
                leagueID = id
            } else {
                print("MatchesView - could not get id for \(league)")
                continue
            }
            
            var sectionSnapShot = dataSource.snapshot(for: league)
            //sectionSnapShot.append([league])
            
            // Get matches for current day + current league
            var matches = [ObjectContainer]()
            let currentDayMatches = QuickCache.helper.matchesByDateDictionary[currentDate.asKey]
            let leagueMatches = QuickCache.helper.matchesByLeagueDictionary[leagueID]
            let intersectingMatchIDs = leagueMatches?.intersection(currentDayMatches ?? [])
            for id in intersectingMatchIDs ?? [] {
                let object = ObjectContainer(matchId: id)
                matches.append(object)
            }
            
            // Sort Matches
            matches.sort { $0.matchId ?? "" < $1.matchId ?? "" }
            
            guard !matches.isEmpty else { continue }
            
            
            // Apply the matches to the section snapshot

            sectionSnapShot.applyDifferences(newItems: [league] + matches)
            sectionSnapShot.expand([league])
            dataSource.apply(sectionSnapShot, to: league, animatingDifferences: true)
        }
    }
    
    @objc func updateMatches() {
        Task.init {
            print("MatchesView - Update matches")
            let updatedDictionary = try await DataFetcher.helper.updateMatches()
            print("MatchesView - Dictionary Retreived")
            
            let numberOfSections = collectionView.numberOfSections
            for sectionIndex in 0 ..< numberOfSections {
                let numberOfItems = collectionView.numberOfItems(inSection: sectionIndex)
                for itemIndex in 0 ..< numberOfItems {
                    let item = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex))
                    if let cell = item as? MatchCell, let matchId = cell.objectContainer?.matchId, let updatedMatch = updatedDictionary[matchId] {
                        cell.updateScore(with: updatedMatch)
                    }
                }
            }
            
            print("MatchesView - End refresh matches")
            self.refreshControl.endRefreshing()
        }
    }
}

extension MatchesView {
    
    func clearCells() {
        let dataSourceSnapshot = NSDiffableDataSourceSnapshot<ObjectContainer, ObjectContainer>()
        dataSource.apply(dataSourceSnapshot, animatingDifferences: true)
    }
    
    @objc func nextDay() {
        var dateComponent = DateComponents()
        dateComponent.day = 1
        
        currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? currentDate
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        
        refresh()
    }
    
    @objc func previousDay() {
        var dateComponent = DateComponents()
        dateComponent.day = -1
        
        currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? currentDate
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        
        refresh()
    }
    
    func refresh() {
        
        clearCells()
        applyData()
    }
}

extension MatchesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Did select")
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MatchCell, let match = cell.objectContainer else { return }
        
        print(match.match?.homeTeamScore, match.match?.awayTeamScore)
    }
}
