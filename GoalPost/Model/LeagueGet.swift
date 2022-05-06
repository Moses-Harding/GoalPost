// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let leagueResults = try? newJSONDecoder().decode(LeagueResults.self, from: jsonData)

import Foundation

// MARK: - LeagueResults
struct GetLeague: Codable {
    let get: String
    let parameters, errors: [String?]
    let results: Int
    let paging: Paging
    let response: [Response]
}

// MARK: - Paging
struct GetLeaguePaging: Codable {
    let current, total: Int
}

// MARK: - Response
struct GetLeagueResponse: Codable {
    let league: GetLeagueLeague
    let country: GetLeagueCountry
    let seasons: [GetLeagueSeason]
}

// MARK: - Country
struct GetLeagueCountry: Codable {
    let name: String
    let code: String?
    let flag: String?
}

// MARK: - League
struct GetLeagueLeague: Codable {
    let id: Int
    let name: String
    let type: TypeEnum
    let logo: String
}

enum TypeEnum: Codable {
    case cup
    case league
}

// MARK: - Season
struct GetLeagueSeason: Codable {
    let year: Int
    let start, end: String
    let current: Bool
    let coverage: GetLeagueCoverage
}

// MARK: - Coverage
struct GetLeagueCoverage: Codable {
    let fixtures: GetLeagueFixtures
    let standings, players, topScorers, topAssists: Bool
    let topCards, injuries, predictions, odds: Bool
}

// MARK: - Fixtures
struct GetLeagueFixtures: Codable {
    let events, lineups, statisticsFixtures, statisticsPlayers: Bool
}
