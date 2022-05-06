//
//  Main Screen View.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

class MainScreenView: UIView {
    
    // MARK: Views
    
    var mainStack = CustomStack(.vertical)
    
    var dateArea = UIStackView(.horizontal)
    var collectionArea = UIView()
    var buttonArea = UIView()

    var collectionView: UICollectionView!
    
    // MARK: Buttons
    
    var upcomingFixturesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Upcoming Fixtures", for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(upcomingFixturesAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    } ()
    
    var nextDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.tintColor = Colors.green.hex7AE7C7
        button.addTarget(self, action: #selector(nextDay), for: .touchUpInside)
        return button
    } ()
    
    var previousDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.tintColor = Colors.green.hex7AE7C7
        button.addTarget(self, action: #selector(previousDay), for: .touchUpInside)
        return button
    } ()
    
    // MARK: Labels
    
    var dateLabel = UILabel()
    
    // MARK: Data
    
    var liveFixtureData = LiveFixtureDataContainer()
    var currentDate = Date()
    
    var dataSource: UICollectionViewDiffableDataSource<LeagueData, ListItem>!
    
    // MARK: Gestures
    
    let swipeRecognizer = UISwipeGestureRecognizer()
    
    init() {
        super.init(frame: CGRect.zero)
        
        setUpMainStack()
        setUpDate()
        setUpButtons()
        setUpCollectionView()
        setUpDataSourceSnapshots()
        setUpColors()
        
        liveFixtureData.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    func setUpMainStack() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(dateArea, 0.075), (collectionArea, 0.84), (viewName: buttonArea, 0.075)])
    }
    
    func setUpDate() {
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        dateLabel.font = UIFont.systemFont(ofSize: 40)
        dateLabel.textAlignment = .center
        dateArea.add(children: [(previousDayButton, 0.2), (dateLabel, 0.6), (nextDayButton, nil)])
    }
    
    func setUpButtons() {
        buttonArea.constrain(upcomingFixturesButton, using: .scale, widthScale: 0.7, heightScale: 0.25, padding: 0, except: [], debugName: "Button Area Constraint")
    }
    
    func setUpCollectionView() {
        // MARK: Create list layout
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.headerTopPadding = 0
        layoutConfig.backgroundColor = Colors.green.hex7AE7C7
        layoutConfig.showsSeparators = true
        layoutConfig.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        
        // MARK: Configure Collection View
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: listLayout)
        collectionArea.constrain(collectionView)
        
        // MARK: Cell registration
        let leagueCellRegistration = UICollectionView.CellRegistration<LeagueCell, LeagueData> {
            (cell, indexPath, league) in
            
            cell.league = league
            
            // With this accessory, the header cell's children will expand / collapse when the header cell is tapped.
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header, isHidden: false, reservedLayoutWidth: .custom(0.001), tintColor: .black)
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
        }
        
        let fixtureCellRegistration = UICollectionView.CellRegistration<FixtureCell, FixtureData> {
            (cell, indexPath, fixture) in
            
            cell.fixture = fixture
        }
        
        
        // MARK: Initialize data source
        dataSource = UICollectionViewDiffableDataSource<LeagueData, ListItem>(collectionView: collectionView) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .league(let league):
            
                // Dequeue league cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: leagueCellRegistration, for: indexPath, item: league)
                return cell
            
            case .fixture(let fixtureItem):
                
                // Dequeue fixture cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: fixtureCellRegistration, for: indexPath, item: fixtureItem)
                return cell
            }
        }
    }
    
    func setUpDataSourceSnapshots() {
        // MARK: Setup snapshots
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<LeagueData, ListItem>()

        // Create collection view section based on number of HeaderItem in modelObjects
        var leaguesList = [LeagueData]()
        liveFixtureData.leagues.forEach { leaguesList.append($0.value) }
        dataSourceSnapshot.appendSections(leaguesList)
        dataSource.apply(dataSourceSnapshot)
        
        // Loop through each header item so that we can create a section snapshot for each respective header item.
        for league in leaguesList {
            
            // Create a section snapshot
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
            
            // Create a header ListItem & append as parent
            let leagueListItem = ListItem.league(league)
            sectionSnapshot.append([leagueListItem])
            
            // Create an array of symbol ListItem & append as child of headerListItem
            let symbolListItemArray = league.fixtures.map { ListItem.fixture($0) }
            sectionSnapshot.append(symbolListItemArray, to: leagueListItem)
            
            // Expand this section by default
            sectionSnapshot.expand([leagueListItem])
            
            // Apply section snapshot to the respective collection view section
            dataSource.apply(sectionSnapshot, to: league, animatingDifferences: false)
        }
    }
    
    // NOTE: CollectionView backgroundColor is set up by changing the layout color in setUpCollectionView
    func setUpColors() {
        dateLabel.textColor = Colors.green.hex7AE7C7
        dateArea.backgroundColor = .black
        buttonArea.backgroundColor = .black
    }
    //NOTE: Configuration of cell body: https://swiftsenpai.com/development/uicollectionview-list-custom-cell/
}

//MARK: Button Actions
extension MainScreenView {
    
    @objc func upcomingFixturesAction() {
        print("Upcoming fixtures pressed")
    }
    
    @objc func nextDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = liveFixtureData.getNextDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        liveFixtureData.retrieveFixtureData(for: currentDate)
        
    }
    
    @objc func previousDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = liveFixtureData.getPreviousDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        liveFixtureData.retrieveFixtureData(for: currentDate)
    }
}

// MARK: Changes

extension MainScreenView {
    func changeDate(to date: Date) {
        dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    }
}

// MARK: Protocols

extension MainScreenView: Refreshable {
    func refresh() {
        setUpDataSourceSnapshots()
    }
}
