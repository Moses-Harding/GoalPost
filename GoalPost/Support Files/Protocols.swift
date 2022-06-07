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
    func refresh()
    func add(team: TeamObject)
}

protocol MatchesViewDelegate {
    func refresh()
}


protocol TeamDataStackDelegate {
    func updateInjurySection(with injuryIDs: Set<InjuryID>?)
    func updateMatchSection(with matchIDs: Set<MatchID>?)
    func updateTransferSection(with transferIDs: Set<TransferID>?)
}

protocol LeagueSearchDelegate {
    func returnSearchResults(leagueResult: [LeagueObject])
    func add(league: LeagueObject)
}

protocol AccessibleObject {
    func returnSelf() -> AccessibleObject
}
