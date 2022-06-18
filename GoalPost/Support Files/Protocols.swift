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
    func refresh(calledBy: String)
    func add(team: TeamObject)
    func remove(team: TeamObject)
}

protocol MatchesViewDelegate {
    func refresh()
}

protocol LeagueSearchDelegate {
    func returnSearchResults(leagueResult: [LeagueObject])
    func add(league: LeagueObject)
}

protocol AccessibleObject {
    func returnSelf() -> AccessibleObject
}
