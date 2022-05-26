// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getLeague = try? newJSONDecoder().decode(GetLeague.self, from: jsonData)

import Foundation

// MARK: - GetLeague
struct LeagueSearchStructure: Codable {
    let response: [LeagueSearchInformation]
}

struct LeagueSearchInformation: Codable, Hashable {
    let league: LeagueSearchInformation_League?
    let country: LeagueSearchInformation_Country?
    let seasons: [LeagueSearchInformation_Seasons]
}

struct LeagueSearchInformation_League: Codable, Hashable {
    let id: Int
    let name: String
    let type: LeagueSearchInformation_League_Type
    let logo: String?
}

enum LeagueSearchInformation_League_Type: String, Codable, Hashable {
    case league = "League"
    case cup = "Cup"
}

struct LeagueSearchInformation_Country: Codable, Hashable {
    let name: String
    let code: String?
    let flag: String?
}

struct LeagueSearchInformation_Seasons: Codable, Hashable {
    let year: Int
    let start: String
    let end: String
    let current: Bool
    let coverage: LeagueSearchInformation_Seasons_Coverage
}

struct LeagueSearchInformation_Seasons_Coverage: Codable, Hashable {
    let fixtures: LeagueSearchInformation_Seasons_Coverage_Fixtures
    let standings: Bool
    let players: Bool
    let top_scorers: Bool
    let top_assists: Bool
    let top_cards: Bool
    let injuries: Bool
    let predictions: Bool
    let odds: Bool
}

struct LeagueSearchInformation_Seasons_Coverage_Fixtures: Codable, Hashable {
    let events: Bool
    let lineups: Bool
    let statistics_fixtures: Bool
    let statistics_players: Bool
}
