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
    
    func refresh(calledBy: String)
    func add(team: TeamObject)
    func remove(team: TeamObject)
    func present(_ viewController: UIViewController, completion: (() -> Void)?)
}

protocol LeaguesViewDelegate {
    var collectionView: UICollectionView { get set }
    
    func refresh(calledBy: String)
    func add(league: LeagueObject)
    func remove(league: LeagueObject)
    func present(_ viewController: UIViewController, completion: (() -> Void)?)
}

protocol MatchesViewDelegate {
    func refresh()
}

protocol AccessibleObject {
    func returnSelf() -> AccessibleObject
}
