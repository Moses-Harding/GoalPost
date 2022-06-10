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
    var heightConstraint: NSLayoutConstraint?
    
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
        
        heightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: totalHeight)
        heightConstraint?.isActive = true
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
        snapshot.appendSections([.match, .transfer, .injury])
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
    
    func updateSnapshot() {
        
        // MARK: Setup snap shots
        guard let dataSource = dataSource, let teamID = team?.id  else { return }
        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        snapshot.appendSections([.match, .injury, .transfer])

        updateMatchSection()
        updateTransferSection()
        updateInjurySection()
    }
    
    func setUpColors() {
        self.collectionView.backgroundColor = Colors.teamDataStackBackgroundColor
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TeamDataStack {
    
    /*
    func updateTransferSection(with transferIDs: Set<TransferID>?) {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating transfer section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let transferIDs = transferIDs else { return }
            
            //print("Transfer Ids found for \(self.team?.name) - \(transferIDs)")
            
            var snapshot = dataSource.snapshot(for: .transfer)
            //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>().
            
            var transfers = [TeamDataObject]()
            
            for transferId in transferIDs.sorted(by: { $0 > $1 } ) {
                transfers.append(TeamDataObject(transferId: transferId))
            }
            
            //print("Trnasfers found for \(self.team?.name) - \(transfers)")
            
            //snapshot.append(transfers)
            snapshot.deleteAll()
            snapshot.append(transfers)
            dataSource.apply(snapshot, to: .transfer, animatingDifferences: false)
            //self.collectionView.reloadData()
        }
    }
    
    func updateMatchSection(with matchIDs: Set<MatchUniqueID>?) {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating match section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let matchIDs = matchIDs else { return }
            
            //print("match Ids found for \(self.team?.name) - \(matchIDs)")
            
            var snapshot = dataSource.snapshot(for: .match)
            //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
            
            var matches = [TeamDataObject]()
            
            for matchId in matchIDs.sorted(by: { $0 > $1 } ) {
                matches.append(TeamDataObject(matchId: matchId))
            }
            
            //print("match found for \(self.team?.name) - \(matches)")

            snapshot.deleteAll()
            snapshot.append(matches)
            dataSource.apply(snapshot, to: .match, animatingDifferences: false)
            //self.collectionView.reloadData()
        }
    }
    
    func updateInjurySection(with injuryIDs: Set<InjuryID>?) {
    /// Updates only the injury section
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating injury section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let injuryIDs = injuryIDs else { return }
            
            //print("injury Ids found for \(self.team?.name) - \(injuryIDs)")
            
            var snapshot = dataSource.snapshot(for: .injury)
            //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
            
            var injuries = [TeamDataObject]()
            
            for injuryId in injuryIDs.sorted(by: { $0 > $1 } ) {
                injuries.append(TeamDataObject(injuryId: injuryId))
            }
            
            //print("injury found for \(self.team?.name) - \(injuries)")
            
            snapshot.deleteAll()
            snapshot.append(injuries)
            dataSource.apply(snapshot, to: .injury, animatingDifferences: false)
            //dataSource.applySnapshotUsingReloadData(snapshot)
            //self.collectionView.reloadData()
        }
    }
    */
    
    func updateTransferSection() {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating transfer section for \(self.team?.name)")
            
            guard let dataSource = self.dataSource, let teamId = self.team?.id, let transferIDs = Cached.transfersByTeam[teamId] else { return }
            
            //print("Transfer Ids found for \(self.team?.name) - \(transferIDs)")
            
            var snapshot = dataSource.snapshot(for: .transfer)
            //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>().
            
            var transfers = [TeamDataObject]()
            
            for transferId in transferIDs.sorted(by: { $0 > $1 } ) {
                transfers.append(TeamDataObject(transferId: transferId))
            }
            

            snapshot.deleteAll()
            snapshot.append(transfers)
            dataSource.apply(snapshot, to: .transfer, animatingDifferences: false)
            //self.collectionView.reloadData()
        }
    }
    
    func updateMatchSection() {
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating match section for \(self.team?.name)")
            
            //guard let dataSource = self.dataSource, let matchIDs = matchIDs else { return }
            
            guard let dataSource = self.dataSource, let teamId = self.team?.id, let matchIDs = Cached.matchesByTeam[teamId] else { return }
            
            //print("match Ids found for \(self.team?.name) - \(matchIDs)")
            
            var snapshot = dataSource.snapshot(for: .match)
            //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
            
            var matches = [TeamDataObject]()
            
            for matchId in matchIDs.sorted(by: { $0 > $1 } ) {
                matches.append(TeamDataObject(matchId: matchId))
            }
            
            //print("match found for \(self.team?.name) - \(matches)")

            snapshot.deleteAll()
            snapshot.append(matches)
            dataSource.apply(snapshot, to: .match, animatingDifferences: false)
            //self.collectionView.reloadData()
        }
    }
    
    func updateInjurySection() {
    /// Updates only the injury section
        DispatchQueue.main.async {
            
            print("TeamDataStack - Updating injury section for \(self.team?.name)")
            
            //guard let dataSource = self.dataSource, let injuryIDs = injuryIDs else { return }
            
            guard let dataSource = self.dataSource, let teamId = self.team?.id, let injuryIDs = Cached.injuriesByTeam[teamId] else { return }
            
            //print("injury Ids found for \(self.team?.name) - \(injuryIDs)")
            
            var snapshot = dataSource.snapshot(for: .injury)
            //var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
            
            var injuries = [TeamDataObject]()
            
            for injuryId in injuryIDs.sorted(by: { $0 > $1 } ) {
                injuries.append(TeamDataObject(injuryId: injuryId))
            }
            
            //print("injury found for \(self.team?.name) - \(injuries)")
            
            snapshot.deleteAll()
            snapshot.append(injuries)
            dataSource.apply(snapshot, to: .injury, animatingDifferences: false)
            //dataSource.applySnapshotUsingReloadData(snapshot)
            //self.collectionView.reloadData()
        }
    }
    
    func manualRefresh() {
        print("Team Data Stack - Refreshing for \(team?.name)")
        self.updateSnapshot()
    }
}
