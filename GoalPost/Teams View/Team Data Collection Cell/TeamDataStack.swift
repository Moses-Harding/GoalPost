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
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 600).isActive = true
    }
        
    func setUpCollectionView() {
        
        collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - InjuryTeamDataStack")
        
        collectionView.register(InjuryCollectionCell.self, forCellWithReuseIdentifier: String(describing: InjuryCollectionCell.self))
        collectionView.register(MatchCollectionCell.self, forCellWithReuseIdentifier: String(describing: MatchCollectionCell.self))
        
        
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
        snapshot.appendSections([.injury])
        snapshot.appendItems([])
        dataSource?.apply(snapshot)
    }
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        let sectionProvider = { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))//.absolute(300))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300),
                                                   heightDimension: .absolute(300))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 5
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(44))
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
    
    private func getInjuries() -> [TeamDataObject] {
        
        guard let teamID = team?.id, let injuryDict = Cached.injuriesByTeam[teamID] else { return [] }
        
        var foundInjuries = [TeamDataObject]()

        for injuryId in injuryDict.sorted(by: { $0 > $1 } ) {
            foundInjuries.append(TeamDataObject(injuryId: injuryId))
        }
        
        //var injuries = Array(foundInjuries.sorted { $0.id > $1.id }[0 ... 15])
        
        //var injuries = Array(foundInjuries[0 ... 20])
        let injuries = foundInjuries//.sorted { $0.id > $1.id }
        
        injuries.forEach {
            print($0.id)
        }
        
        return injuries
        //return []
    }
    
    func getMatches() -> [TeamDataObject] {
        
        guard let teamID = team?.id, let matchIds = Cached.matchesByTeam[teamID] else { return [] }
        
        var foundMatches = [TeamDataObject]()
        
        for id in matchIds.sorted { $0 > $1 } {
            foundMatches.append(TeamDataObject(matchId: id))
        }

        //let matches = Array(foundMatches[0 ... 15])
        
        //return matches
        //return []
        return foundMatches
    }
    
    func updateSnapshot() {
        // MARK: Setup snap shots
        guard let dataSource = dataSource else { return }
        

        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        snapshot.appendSections([.injury, .match])
        
        let injuries = getInjuries()
        let matches = getMatches()
        
        snapshot.appendItems(injuries, toSection: .injury)
        snapshot.appendItems(matches, toSection: .match)
        
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

extension TeamDataStack: Refreshable {
    func refresh() {
        self.updateSnapshot()
    }
}
