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

protocol MatchesViewDelegate {
    func refresh()
}

protocol TeamSearchDelegate {
    var spinner: UIActivityIndicatorView? { get set }
    
    func returnSearchResults(teamResult: [TeamObject])
    func add(team: TeamObject)
    func addSpinner()
    func removeSpinner()
}

protocol LeagueSearchDelegate {
    func returnSearchResults(leagueResult: [LeagueObject])
    func add(league: LeagueObject)
}

protocol AccessibleObject {
    func returnSelf() -> AccessibleObject
}
