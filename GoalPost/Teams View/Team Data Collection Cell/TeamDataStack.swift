//
//  TeamDataStack.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

class TeamDataStack: UIStackView {
    
    
    var dataSource: UICollectionViewDiffableDataSource<TeamDataObjectType, TeamDataObject>?
    
    let collectionViewArea = UIView()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    var totalHeight: CGFloat = 1200
    
    // Data
    var team: TeamObject?
    
    var matchLoading = false
    var injuryLoading = false
    var transferLoading = false
    var playerLoading = false
    
    init(team: TeamObject?) {
        super.init(frame: .zero)
        
        self.team = team
        self.axis = .vertical
        
        setUpMainStack()
        setUpCollectionView()
        setUpColors()
    }
    
    func setUpMainStack() {
        // Set Up Structure
        self.add([collectionViewArea])
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: totalHeight).isActive = true
    }
    
    func setUpCollectionView() {
        
        collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - InjuryTeamDataStack")
        
        collectionView.register(MatchCollectionCell.self, forCellWithReuseIdentifier: String(describing: MatchCollectionCell.self))
        collectionView.register(InjuryCollectionCell.self, forCellWithReuseIdentifier: String(describing: InjuryCollectionCell.self))
        collectionView.register(TransferCollectionCell.self, forCellWithReuseIdentifier: String(describing: TransferCollectionCell.self))
        collectionView.register(PlayerCollectionCell.self, forCellWithReuseIdentifier: String(describing: PlayerCollectionCell.self))
        
        
        dataSource = UICollectionViewDiffableDataSource<TeamDataObjectType, TeamDataObject>(collectionView: collectionView) {
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
            }
        }
        collectionView.dataSource = dataSource
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: ElementKind.titleElementKind.rawValue) {
            (supplementaryView, elementKind, indexPath) in
            if let snapshot = self.dataSource?.snapshot() {
                // Populate the view with our section's description.
                let category = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = category.rawValue
            }
        }
        
        dataSource?.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        snapshot.appendSections([.match, .transfer, .injury, .player])
        dataSource?.apply(snapshot)
    }
    
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
            
            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300),
                                                   heightDimension: .absolute(cellSize))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = spacingSize
            section.contentInsets = NSDirectionalEdgeInsets(top: insetSize, leading: insetSize, bottom: insetSize, trailing: insetSize)
            
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
    
    func updateSnapshot() {
        
        print("TeamDataStack - Update Snapshot for \(team)")
        
        // MARK: Setup snap shots
        guard let dataSource = dataSource, let teamID = team?.id  else { return }
        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        snapshot.appendSections([.match, .injury, .transfer, .player])

        updateMatchSection()
        updateTransferSection()
        updateInjurySection()
        updatePlayerSection()
    }
    
    func setUpColors() {
        self.collectionView.backgroundColor = Colors.teamDataStackBackgroundColor
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TeamDataStack {
    
    func update(_ section: TeamDataObjectType, with objects: [TeamDataObject]) {
        guard let dataSource = self.dataSource else {
                print("TeamDataStack - DataSource not found!")
            return
        }
        
        self.load(section)
        
        DispatchQueue.main.async {

            var snapshot = dataSource.snapshot(for: section)
            
            snapshot.deleteAll()
            snapshot.append(objects)
            dataSource.apply(snapshot, to: section, animatingDifferences: false)
        }
    }
    
    func updateTransferSection() {
        
        print("TeamDataStack - Update Transfer Section for \(team)")
        
        if transferLoading {
            self.load(.transfer)
            return
        }
        
        Task.init {
            
            guard let dataSource = self.dataSource, let teamId = self.team?.id, let transferIDs = await Cached.data.transfersByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .transfer)

            var transfers = [TeamDataObject]()
            
            for transferId in transferIDs.sorted(by: { $0 > $1 } ) {
                transfers.append(TeamDataObject(transferId: transferId))
            }
            
            snapshot.deleteAll()
            snapshot.append(transfers)
            await dataSource.apply(snapshot, to: .transfer, animatingDifferences: false)
        }
    }
    
    func updateMatchSection() {
        
        print("TeamDataStack - Update Match Section for \(team)")
        
        if matchLoading {
            self.load(.match)
            return
        }
        
        Task.init {

            guard let dataSource = self.dataSource, let teamId = self.team?.id, let matchIDs = await Cached.data.matchesByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .match)

            var matches = [TeamDataObject]()
            
            for matchId in matchIDs.sorted(by: { $0 > $1 } ) {
                matches.append(TeamDataObject(matchId: matchId))
            }

            snapshot.deleteAll()
            snapshot.append(matches)
            await dataSource.apply(snapshot, to: .match, animatingDifferences: false)
        }
    }
    
    func updateInjurySection() {

        print("TeamDataStack - Update Injury Section for \(team)")
        
        if injuryLoading {
            self.load(.injury)
            return
        }
        
        Task.init {

            guard let dataSource = self.dataSource, let teamId = self.team?.id, let injuryIDs = await Cached.data.injuriesByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .injury)

            var injuries = [TeamDataObject]()
            
            for injuryId in injuryIDs.sorted(by: { $0 > $1 } ) {
                injuries.append(TeamDataObject(injuryId: injuryId))
            }

            snapshot.deleteAll()
            snapshot.append(injuries)
            await dataSource.apply(snapshot, to: .injury, animatingDifferences: false)
        }
    }
    
    func updatePlayerSection() {

        print("TeamDataStack - Update Player Section for \(team)")
        
        if playerLoading {
            self.load(.player)
            return
        }
        
        Task.init {

            guard let dataSource = self.dataSource, let teamId = self.team?.id, let playerIDs = await Cached.data.playersByTeam[teamId] else { return }

            var snapshot = dataSource.snapshot(for: .player)

            var players = [TeamDataObject]()
            
            for playerId in playerIDs.sorted(by: { $0 < $1 } ) {
                players.append(TeamDataObject(playerId: playerId))
            }
            
            snapshot.deleteAll()
            snapshot.append(players)
            await dataSource.apply(snapshot, to: .player, animatingDifferences: false)
        }
    }

    
    func load(_ sectionType: TeamDataObjectType) {
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
        
        var snapshot = dataSource.snapshot(for: .injury)
        let loading = TeamDataObject(type: sectionType, loading: true)
        snapshot.deleteAll()
        snapshot.append([loading])
        dataSource.apply(snapshot, to: sectionType, animatingDifferences: false)
    }
    
    func manualRefresh() {
        print("Team Data Stack - Refreshing for \(team)")
        self.updateSnapshot()
    }
}
