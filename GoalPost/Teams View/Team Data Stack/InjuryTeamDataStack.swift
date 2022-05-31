//
//  InjuryTeamDataStack.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

/*
class InjuryTeamDataStack: TeamDataStack {
    
    var dataSource: UICollectionViewDiffableDataSource<TeamDataObjectType, InjuryObject>?
    
    override func setUpCollectionView() {
        
        collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - InjuryTeamDataStack")
        
        collectionView.register(InjuryCollectionCell.self, forCellWithReuseIdentifier: String(describing: InjuryCollectionCell.self))
        
        dataSource = UICollectionViewDiffableDataSource<TeamDataObjectType, InjuryObject>(collectionView: collectionView) {
            (collectionView, indexPath, injuryInformation) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: InjuryCollectionCell.self),
                for: indexPath) as? InjuryCollectionCell else {
                fatalError("Could not cast cell as \(InjuryCollectionCell.self)")
            }
            
            cell.injuryInformation = injuryInformation
            return cell
        }
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, InjuryObject>()
        snapshot.appendTeamDataObjectTypes([.main])
        snapshot.appendItems([])
        dataSource?.apply(snapshot)
    }
    
    override func updateSnapshot() {
        // MARK: Setup snap shots
        
        var foundInjuries = [InjuryObject]()
        
        guard let teamID = team?.id, let injuryDict = Cached.injuryDictionary[teamID] else { return }
        
        for injury in injuryDict.sorted(by: { $0.match.timeStamp > $1.match.timeStamp }) {
            foundInjuries.append(injury)
        }
        
        //var injuries = Array(foundInjuries[0 ... 15])
        var injuries = Array(foundInjuries[0 ... 1])
        
        guard let dataSource = dataSource else { return }
        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, InjuryObject>()
        snapshot.appendTeamDataObjectTypes([])
        snapshot.appendItems(injuries, toTeamDataObjectType: .main)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
*/
