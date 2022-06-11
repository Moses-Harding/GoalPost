// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getInjuries = try? newJSONDecoder().decode(GetInjuries.self, from: jsonData)

import Foundation

// MARK: - GetInjuries
struct GetInjuriesStructure: Codable {
    let response: [GetInjuriesInformation]
}

// MARK: - Response
struct GetInjuriesInformation: Codable {
    let player: GetInjuriesInformation_Player
    let team: GetInjuriesInformation_Team
    let fixture: GetInjuriesInformation_Fixture
    let league: GetInjuriesInformation_League
}

// MARK: - Fixture
struct GetInjuriesInformation_Fixture: Codable {
    let id: Int
    let timezone: String
    let date: String
    let timestamp: Int
}

// MARK: - League
struct GetInjuriesInformation_League: Codable {
    let id: Int
    let season: Int
    let name: String
    let country: String
    let logo: String
    let flag: String?
}

// MARK: - Player
struct GetInjuriesInformation_Player: Codable {
    let id: Int
    let name: String
    let photo: String
    let type: String
    let reason: String
}

enum GetInjuriesInformation_Player_Type: String, Codable {
    case missingFixture
    case questionable
}

// MARK: - Team
struct GetInjuriesInformation_Team: Codable {
    let id: Int
    let name: String
    let logo: String
}
