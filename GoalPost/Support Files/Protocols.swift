//
//  Protocols.swift
//  GoalPost
//
//  Created by Moses Harding on 5/3/22.
//

import Foundation
import UIKit

protocol Refreshable {
    func refresh()
}

protocol TeamsViewDelegate {
    var collectionView: UICollectionView { get set }
    
    func refresh(calledBy: String, expandingCell id: Int?)
    func add(team: TeamObject)
    func remove(team: TeamObject)
    func present(_ viewController: UIViewController, completion: (() -> Void)?)
}

protocol MatchesViewDelegate {
    func refresh()
}

protocol LeagueSearchDelegate {
    func refresh()
    func add(league: LeagueObject)
}

protocol AccessibleObject {
    func returnSelf() -> AccessibleObject
}
