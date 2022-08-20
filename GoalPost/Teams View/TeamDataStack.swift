//
//  TeamDataStack.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

/*
 DOCUMENTATION
 
 TeamDataStack includes a collectionView that has data for every relevant section (match, transfer, etc) split up into separate sections. The sections are divided with a titleSupplementaryView
 
NOTE: As of 8/4/22, only the matches section is included.
 
 1. Initialization requires a teamObject. The UI (MainStack) is implemented, which only contains the collectionView.
 2. When the collectioNView is referenced, it is lazily constructed using createCollectionViewLayout()
 3. Each relevant collectioncell is registered (e.g. matchCollectionCell), as well as titleSupplementaryViews for each section
 
 External Triggers
 manualRefresh - Triggered when a teamCollectionCell is selected. At the same time, the body of that cell (which includes teamDataStack) is unhidden. This triggers each section of the teamDataStack's collectionView to update with the latest data from the cache.
 update_Section - Triggered one of two ways. 1. manualRefresh (above) is triggered by selecting the cell. 2. DataFetcher completes retrieving info about the given section (when a new team is added). Data is read from the dictionary, and then assigned to the datasource, which in turns creates relevant cells.
 load - Triggered by teamsView.add(). When a team is added, each section is set to "load" (simply show a cell with a waiting indicator). This cell gets removed once the DataFetcher retreives all relevant information and triggers update_Section
 
 */

class TeamDataStack: UIStackView {
    
    
    var dataSource: UICollectionViewDiffableDataSource<TeamDataObjectType, ObjectContainer>?
    
    let collectionViewArea = UIView()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    //var totalHeight: CGFloat = 1200
    var totalHeight: CGFloat = 300
    
    // Data
    var team: TeamObject?
    
    //var matchLoading = false
    //var injuryLoading = false
    //var transferLoading = false
    //var playerLoading = false
    
    init(team: TeamObject?) {
        super.init(frame: .zero)
        
        self.team = team
        self.axis = .vertical
        
        setUpMainStack()
        setUpCollectionView()
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        // Set Up Structure
        self.add([collectionViewArea])
        collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - InjuryTeamDataStack")
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: totalHeight).isActive = true
    }
    
    // 1.5 - Called when collectionView is accessed for the first time
    func createCollectionViewLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        let titleHeight: CGFloat = 40
        let insetSize: CGFloat = 10
        let spacingSize: CGFloat = 5
        
        let cellSize: CGFloat = 200
        
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Set the size of the item to the size of its parent group
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Set the size of the group to  and absolute of 300 x 200
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300),
                                                   heightDimension: .absolute(cellSize))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Add spacing / insets to the section, and indicate that it should scroll left-to-right
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = spacingSize
            section.contentInsets = NSDirectionalEdgeInsets(top: insetSize, leading: insetSize, bottom: insetSize, trailing: insetSize)
            
            // Set the title dimensions to match the width of the group, with an estimated height of 40
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(titleHeight))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: ElementKind.titleElementKind.rawValue,
                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
    
    // 2
    func setUpCollectionView() {
        
        // 1. Register each cell type
        collectionView.register(MatchCollectionCell.self, forCellWithReuseIdentifier: String(describing: MatchCollectionCell.self))
        collectionView.register(InjuryCollectionCell.self, forCellWithReuseIdentifier: String(describing: InjuryCollectionCell.self))
        collectionView.register(TransferCollectionCell.self, forCellWithReuseIdentifier: String(describing: TransferCollectionCell.self))
        collectionView.register(PlayerCollectionCell.self, forCellWithReuseIdentifier: String(describing: PlayerCollectionCell.self))
        
        
        // 2. Create the datasource, which expects a collectionview, indexpath, and teamdataobject. If the type is match, for example, the datasource dequeues a matchCollectionCell, assigns the teamDataObject to it (triggering 'updateAppearance') and returns the cell
        dataSource = UICollectionViewDiffableDataSource<TeamDataObjectType, ObjectContainer>(collectionView: collectionView) {
            (collectionView, indexPath, teamDataObject) -> UICollectionViewCell? in
            
            switch teamDataObject.type {
            case .match:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: MatchCollectionCell.self),
                    for: indexPath) as? MatchCollectionCell else {
                    fatalError("Could not cast cell as \(MatchCollectionCell.self)")
                }
                
                cell.teamDataObject = teamDataObject
                return cell
            case .injury:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: InjuryCollectionCell.self),
                    for: indexPath) as? InjuryCollectionCell else {
                    fatalError("Could not cast cell as \(InjuryCollectionCell.self)")
                }
                
                cell.teamDataObject = teamDataObject
                return cell
            case .transfer:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: TransferCollectionCell.self),
                    for: indexPath) as? TransferCollectionCell else {
                    fatalError("Could not cast cell as \(TransferCollectionCell.self)")
                }
                
                cell.teamDataObject = teamDataObject
                return cell
            case .player:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: PlayerCollectionCell.self),
                    for: indexPath) as? PlayerCollectionCell else {
                    fatalError("Could not cast cell as \(PlayerCollectionCell.self)")
                }
                
                cell.teamDataObject = teamDataObject
                return cell
            case .league:
                fatalError()
            }
        }
        collectionView.dataSource = dataSource
        
        // 3. Create a supplementary view registration. Generate a TitleSupplemenatryView, get the sectionIdentifier (e.g. .match), and set the label in the supplementaryView to the rawValue (in that case, "Matches"). Then provide this registration to the dataSource
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: ElementKind.titleElementKind.rawValue) {
            (supplementaryView, elementKind, indexPath) in
            if let snapshot = self.dataSource?.snapshot() {
                let category = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = category.rawValue
            }
        }
        
        dataSource?.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, ObjectContainer>()
        snapshot.appendSections([.match])
        dataSource?.apply(snapshot)
    }
    
    // 3
    func setUpColors() {
        self.collectionView.backgroundColor = Colors.teamDataStackBackgroundColor
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TeamDataStack {

    func clearCollectionView() {
        guard let dataSource = self.dataSource else { return }
        
        var snapShot = dataSource.snapshot(for: .match)
        snapShot.deleteAll()
        dataSource.apply(snapShot, to: .match, animatingDifferences: true)
    }
    
    func manualRefresh() async {
        /// Called when a cell is selected.
        /// This should call each "updateSection".
        /// __NOTE: As of 8/4, only Matches are included
        
        print("Team Data Stack - Refreshing for \(team?.name ?? "UKNOWN TEAM")")
        
        // MARK: Setup snap shots
        //guard let dataSource = dataSource, let teamID = team?.id  else { return }
        
        // Create a snapshot that define the current state of data source's data
        //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        //snapshot.appendSections([.match])

        await updateMatchSection()
    }
    
    func updateMatchSection() async {
        /// Called when 1. the cell is selected or 2. when teamsView has called DataFetcher to retrieve info about a team, and that operation has completed
        /// Get all of the matches in the dictionary, create a TeamDataObject for each, then apply to datasource. (This triggers the creation of the matchCollectionCells)
        
        print("TeamDataStack - Update Match Section for \(team?.name ?? "UKNOWN TEAM")")
        
        /*
        if matchLoading {
            self.load(.match)
            return
        }
         */

        guard let dataSource = self.dataSource, let teamId = self.team?.id, let matchIDs = await Cached.data.matchesByTeam[teamId] else { return }

        var snapshot = dataSource.snapshot(for: .match)

        var matches = [ObjectContainer]()
        
        var position: Int = 0
        var index: Int = 0
        
        for matchId in matchIDs.sorted(by: { $0 < $1 } ) {
            matches.append(ObjectContainer(matchId: matchId))
            if let matchDate = Double(String(matchId.split(separator: "|")[0])) {
                if matchDate < Date.now.timeIntervalSince1970 {
                    position = index
                }
            }
            index += 1
        }

        snapshot.applyDifferences(newItems: matches)
        
        await dataSource.apply(snapshot, to: .match, animatingDifferences: false)
        
        let indexPath = IndexPath(item: position, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    /*
    func load(_ sectionType: TeamDataObjectType) {
        /// Called by teamsView before it calls DataFetcher to retrieve data about the team for a given section. "Loading" is cancelled once this is complete.
        /// Create a "loading" cell of the given section type, remove everything else in the section, and then apply it
        
        print("TeamDataStack - Loading Section for \(team)")
        guard let dataSource = self.dataSource else { return }
        
        switch sectionType {
        case .match:
            self.matchLoading = true
        case .injury:
            self.injuryLoading = true
        case .transfer:
            self.transferLoading = true
        case .player:
            self.playerLoading = true
        }
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<TeamDataObject>()
        let loading = TeamDataObject(type: sectionType, loading: true)
        snapshot.append([loading])
        dataSource.apply(snapshot, to: sectionType, animatingDifferences: false)
    }
     */
}

extension TeamDataStack {
    
    // VERSION 2
    
    func updateTransferSection() {
        
        print("TeamDataStack - Update Transfer Section for \(team?.name ?? "UKNOWN TEAM")")
        
        /*
        if transferLoading {
            self.load(.transfer)
            return
        }
         */
        
        Task.init {
            
            guard let dataSource = self.dataSource, let teamId = self.team?.id, let transferIDs = await Cached.data.transfersByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .transfer)

            var transfers = [ObjectContainer]()
            
            for transferId in transferIDs.sorted(by: { $0 > $1 } ) {
                transfers.append(ObjectContainer(transferId: transferId))
            }
            
            snapshot.deleteAll()
            snapshot.append(transfers)
            await dataSource.apply(snapshot, to: .transfer, animatingDifferences: false)
        }
    }
    
    
    func updateInjurySection() {

        print("TeamDataStack - Update Injury Section for \(team?.name ?? "UKNOWN TEAM")")
        
        /*
        if injuryLoading {
            self.load(.injury)
            return
        }
         */
        
        Task.init {

            guard let dataSource = self.dataSource, let teamId = self.team?.id, let injuryIDs = await Cached.data.injuriesByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .injury)

            var injuries = [ObjectContainer]()
            
            for injuryId in injuryIDs.sorted(by: { $0 > $1 } ) {
                injuries.append(ObjectContainer(injuryId: injuryId))
            }

            snapshot.deleteAll()
            snapshot.append(injuries)
            await dataSource.apply(snapshot, to: .injury, animatingDifferences: false)
        }
    }
    
    func updatePlayerSection() {

        print("TeamDataStack - Update Player Section for \(team?.name ?? "UKNOWN TEAM")")
        
        /*
        if playerLoading {
            self.load(.player)
            return
        }
         */
        
        Task.init {

            guard let dataSource = self.dataSource, let teamId = self.team?.id, let playerIDs = await Cached.data.playersByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .player)

            var players = [ObjectContainer]()
            
            for playerId in playerIDs.sorted(by: { $0 < $1 } ) {
                players.append(ObjectContainer(playerId: playerId))
            }
            
            snapshot.deleteAll()
            snapshot.append(players)
            await dataSource.apply(snapshot, to: .player, animatingDifferences: false)
        }
    }
}
