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
        button.tintColor = Colors.lightColor
        button.addTarget(self, action: #selector(nextDay), for: .touchUpInside)
        return button
    } ()
    
    var previousDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.tintColor = Colors.lightColor
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
    
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = Colors.darkColor
        mainStack.backgroundColor = Colors.darkColor
        collectionArea.backgroundColor = Colors.darkColor
        
        setUpMainStack()
        setUpDate()
        setUpButtons()
        setUpCollectionView()
        //setUpDataSourceSnapshots()
        setUpColors()
        setUpGestures()
        
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
        dateLabel.font = UIFont.systemFont(ofSize: 20)
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
        layoutConfig.backgroundColor = Colors.lightColor
        layoutConfig.showsSeparators = true
        layoutConfig.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        //listLayout.layoutAttributesForDecorationView(ofKind: <#T##String#>, at: <#T##IndexPath#>)
        
        // MARK: Configure Collection View
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: listLayout)
        collectionArea.constrain(collectionView)
        
        // MARK: Cell registration
        let leagueCellRegistration = UICollectionView.CellRegistration<LeagueCell, LeagueData> {
            (cell, indexPath, league) in
            
            cell.league = league
            
            // With this accessory, the header cell's children will expand / collapse when the header cell is tapped.
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header, isHidden: false, reservedLayoutWidth: .custom(0.001), tintColor: Colors.lightColor)
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
    
    func setUpDataSourceSnapshots(from date: Date) {
        // MARK: Setup snap shots
        
        // Create new datasource snapshot
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<LeagueData, ListItem>()
        
        // Get only the fixtures for the current date
        let currentFixtures = Cached.dailyFixtures[date.asKey] ?? [:]
        
        // Create a list of each league for that date
        var leaguesList = currentFixtures.map { $0.value }
        
        // Sort the leagues alphabetically
        leaguesList.sort { $0.name < $1.name }
        
        // Add sections to the snapshot (just adding an array)
        dataSourceSnapshot.appendSections(leaguesList)
        
        // Apply the snapshot to the datasource
        dataSource.apply(dataSourceSnapshot)
        
        // Create a section snapshot for each league
        for league in leaguesList {
            
            // Create new section snapshot
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
            
            // Create a new "ListItem" object, and assign the current league to it. Then append it to the snapshot
            let leagueListItem = ListItem.league(league)
            sectionSnapshot.append([leagueListItem])
            
            // Create an array of "ListItem" objects and assign each fixture for a given league to it. Then append that list to its "parent"
            let fixtureItems = league.fixtures.map { ListItem.fixture($0) }
            sectionSnapshot.append(fixtureItems, to: leagueListItem)
            
            // Expand this section by default
            sectionSnapshot.expand([leagueListItem])
            
            // Apply section snapshot to the respective collection view section
            dataSource.apply(sectionSnapshot, to: league, animatingDifferences: true)
        }
    }
    
    // NOTE: CollectionView backgroundColor is set up by changing the layout color in setUpCollectionView
    func setUpColors() {
        dateLabel.textColor = Colors.lightColor
        dateArea.backgroundColor = Colors.darkColor
        buttonArea.backgroundColor = Colors.darkColor
        collectionView.backgroundView?.backgroundColor = .clear
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

extension MainScreenView: UICollectionViewDelegate {

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
        refresh()
        
    }
    
    @objc func previousDay() {
        
        // dateLabel set and retrieveData triggered by currentDate willSet
        currentDate = liveFixtureData.getPreviousDay(from: currentDate)
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        refresh()
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
        setUpDataSourceSnapshots(from: currentDate)
    }
}

// MARK: Extensions
extension MainScreenView: UIGestureRecognizerDelegate {
    
}
