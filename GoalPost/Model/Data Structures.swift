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
    var timeElapsed: Int?
    var timeStamp: Date
}

struct FixtureTeamData: Codable, Hashable {
    var name: String
    var id: Int
    var logoURL: String
    var score: Int?
}

/*
struct TeamData: Codable, Hashable {
    var id: Int
    var name: String
    var code: String
    var country: String
    var founded: Int
    var national: Bool
    var logoURL: String
}
*/
