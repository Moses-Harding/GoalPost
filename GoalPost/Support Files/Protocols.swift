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
    func refresh(update: Bool)
}

protocol TeamSearchDelegate {
    var spinner: UIActivityIndicatorView? { get set }
    
    func returnSearchResults(teamResult: [TeamSearchData])
    func add(team: TeamSearchData)
    func addSpinner()
    func removeSpinner()
}

protocol LeagueSearchDelegate {
    func returnSearchResults(leagueResult: [LeagueSearchData])
    func add(league: LeagueSearchData)
}
