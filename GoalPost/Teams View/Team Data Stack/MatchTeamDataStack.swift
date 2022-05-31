//
//  MatchTeamDataStack.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

/*
class MatchTeamDataStack: TeamDataStack {
    
    var dataSource: UICollectionViewDiffableDataSource<TeamDataObjectType, TeamDataObject>?
    
    override func setUpCollectionView() {
        
        collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - InjuryTeamDataStack")
        
        collectionView.register(MatchCollectionCell.self, forCellWithReuseIdentifier: String(describing: MatchCollectionCell.self))
        
        dataSource = UICollectionViewDiffableDataSource<TeamDataObjectType, TeamDataObject>(collectionView: collectionView) {
            (collectionView, indexPath, matchInformation) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MatchCollectionCell.self),
                for: indexPath) as? MatchCollectionCell else {
                fatalError("Could not cast cell as \(MatchCollectionCell.self)")
            }
            
            cell.matchInformation = matchInformation
            return cell
        }
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, TeamDataObject>()
        snapshot.appendSections([.match])
        snapshot.appendItems([])
        dataSource?.apply(snapshot)
    }
    
    override func updateSnapshot() {
        // MARK: Setup snap shots
        

        
        guard let teamID = team?.id, let matchIds = Cached.matchesByTeam[teamID] else { return }
        
        var foundMatches = [MatchObject]()
        
        for id in matchIds.sorted { $0 > $1 } {
            if let match = Cached.matchesDictionary[id] {
                foundMatches.append(match)
            }
        }
        
        //var matches = Array(foundMatches[0 ... 15])
        var matches = Array(foundMatches[0 ... 1])
        
        guard let dataSource = dataSource else { return }
        
        
        //let matches = foundMatches.sorted { $0.timeStamp > $1.timeStamp }.map { $0 }
        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, MatchObject>()
        snapshot.appendSections([.match])
        snapshot.appendItems(matches, toSection: .match)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
*/
