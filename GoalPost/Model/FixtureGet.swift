// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fixtureResults = try? newJSONDecoder().decode(FixtureResults.self, from: jsonData)

import Foundation

// MARK: - FixtureResults
struct FixtureResults: Codable {
    //let get: String
    let parameters: Parameters
    //let errors: [String:String]?
    let results: Int
    let paging: Paging
    let response: [Response]
}

// MARK: - Paging
struct Paging: Codable {
    let current, total: Int
}

// MARK: - Parameters
struct Parameters: Codable {
    let date: String?
}

// MARK: - Response
struct Response: Codable {
    let fixture: Fixture
    let league: League
    let teams: Teams
    let goals: Goals
    let score: Score
}

// MARK: - Response -  Fixture
struct Fixture: Codable {
    let id: Int?
    let referee: String?
    let timezone: String
    let date: String
    let timestamp: Int
    let periods: FixturePeriods
    let venue: FixtureVenue
    let status: FixtureStatus
}

struct FixturePeriods: Codable {
    let first: Int?
    let second: Int?
}

struct FixtureVenue: Codable {
    let id: Int?
    let name: String?
    let city: String?
}

struct FixtureStatus: Codable {
    let long: String
    let short: String
    let elapsed: Int?
}

// MARK: - Response - League
struct League: Codable {
    let id: Int
    let name: String
    let country: String
    let logo: String
    let flag: String?
    let season: Int
    let round: String
}

// MARK: Response - Teams

struct Teams: Codable {
    let home: Team
    let away: Team
}

struct Team: Codable {
    let id: Int
    let name: String
    let logo: String
    let winner: Bool?
}

// MARK: Response - Goals

struct Goals: Codable {
    let home: Int?
    let away: Int?
}

// MARK: Response - Score

struct Score: Codable {
    let halftime: ScoreGoals
    let fulltime: ScoreGoals
    let extratime: ScoreGoals
    let penalty: ScoreGoals
}

struct ScoreGoals: Codable {
    let home: Int?
    let away: Int?
}
