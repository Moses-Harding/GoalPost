//
//  League.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

// MARK: Structures used in LeagueSearchDataContainer

struct LeagueSearchData: Codable, Hashable {
    let id: Int
    let name: String
    let logo: String?
    let type: LeagueSearchInformation_League_Type
    let country: String
    let countryLogo: String?
    let currentSeason: Int
    let seasonStart: String
    let seasonEnd: String
}
