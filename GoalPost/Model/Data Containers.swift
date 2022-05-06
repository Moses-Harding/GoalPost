//
//  Data Containers.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation

struct LeagueData: Codable, Hashable {
    var name: String
    var country: String = "England"
    var id: Int = 0
    var fixtures: [FixtureData]
}

struct FixtureData: Codable, Hashable {
    var homeTeam: FixtureTeamData
    var awayTeam: FixtureTeamData
    var timeElapsed: Float
}

struct FixtureTeamData: Codable, Hashable {
    var name: String
    var score: Int
}
