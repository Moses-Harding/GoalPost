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
    
    var totalHeight: CGFloat = 800
    
    // Data
    var team: TeamObject?
    
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
        snapshot.appendSections([.match, .injury, .transfer])
        snapshot.appendItems([])
        dataSource?.apply(snapshot)
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        var titleHeight: CGFloat = 40
        var insetSize: CGFloat = 10
        var spacingSize: CGFloat = 5
        
        var cellSize = (totalHeight / 4.0) - titleHeight - (insetSize * 2)
        
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
            section.contentInsets = NSDirectionalEdgeInsets(top: insetSize, leading: insetSize, bottom: 0, trailing: insetSize)
            
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
    
    func getMatches() -> [TeamDataObject] {
        
        guard let teamID = team?.id, let matchIds = Cached.matchesByTeam[teamID] else { return [] }
        
        //print(teamID)
        
        var foundMatches = [TeamDataObject]()
        
        for id in matchIds.sorted { $0 > $1 } {
            foundMatches.append(TeamDataObject(matchId: id))
        }
        return foundMatches
    }
    
    private func getInjuries() -> [TeamDataObject] {
        
        //print(Cached.injuriesByTeam[529])
        
        guard let teamID = team?.id, let injuryDict = Cached.injuriesByTeam[teamID] else { return [] }
        
        var foundInjuries = [TeamDataObject]()
        
        for injuryId in injuryDict.sorted(by: { $0 > $1 } ) {
            foundInjuries.append(TeamDataObject(injuryId: injuryId))
        }
        let injuries = foundInjuries
        
        return injuries
    }
    
    private func getTransfers() -> [TeamDataObject] {
        
        //print(Cached.transfersByTeam[529])
        
        guard let teamID = team?.id, let transferDict = Cached.transfersByTeam[teamID] else { return [] }
        
        var foundTransfers = [TeamDataObject]()
        
        for transferId in transferDict.sorted(by: { $0 > $1 } ) {
            foundTransfers.append(TeamDataObject(transferId: transferId))
        }
        let transfers = foundTransfers
        
        
        return transfers
    }
    
    func updateSnapshot() {
        
        // MARK: Setup snap shots
        guard let dataSource = dataSource else { return }
        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        snapshot.appendSections([.injury, .match, .transfer])
        
        let matches = getMatches()
        let injuries = getInjuries()
        let transfers = getTransfers()
        
        //print(matches, injuries, transfers)
        
        snapshot.appendItems(matches, toSection: .match)
        snapshot.appendItems(injuries, toSection: .injury)
        snapshot.appendItems(transfers, toSection: .transfer)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setUpColors() {
        self.collectionView.backgroundColor = Colors.teamDataStackBackgroundColor
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TeamDataStack: TeamDataStackDelegate {
    
    func updateTransferSection(with transferIDs: Set<TransferID>?) {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating transfer section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let transferIDs = transferIDs else { return }
            
            var snapshot = dataSource.snapshot(for: .transfer)
            
            var transfers = [TeamDataObject]()
            
            for transferId in transferIDs.sorted(by: { $0 > $1 } ) {
                transfers.append(TeamDataObject(transferId: transferId))
            }
            
            snapshot.append(transfers)
            dataSource.apply(snapshot, to: .transfer)
            self.collectionView.reloadData()
        }
    }
    
    func updateMatchSection(with matchIDs: Set<MatchID>?) {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating match section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let matchIDs = matchIDs else { return }
            
            var snapshot = dataSource.snapshot(for: .match)
            
            var matches = [TeamDataObject]()
            
            for matchId in matchIDs.sorted(by: { $0 > $1 } ) {
                matches.append(TeamDataObject(matchId: matchId))
            }
            
            snapshot.append(matches)
            dataSource.apply(snapshot, to: .match)
            self.collectionView.reloadData()
        }
    }
    
    func updateInjurySection(with injuryIDs: Set<InjuryID>?) {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating transfer section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let injuryIDs = injuryIDs else { return }
            
            var snapshot = dataSource.snapshot(for: .injury)
            
            var injuries = [TeamDataObject]()
            
            for injuryId in injuryIDs.sorted(by: { $0 > $1 } ) {
                injuries.append(TeamDataObject(injuryId: injuryId))
            }
            
            snapshot.append(injuries)
            dataSource.apply(snapshot, to: .injury)
            self.collectionView.reloadData()
        }
    }
    
    func manualRefresh() {
        print("Team Data Stack - Refreshing for \(team?.name)")
        self.updateSnapshot()
    }
}
