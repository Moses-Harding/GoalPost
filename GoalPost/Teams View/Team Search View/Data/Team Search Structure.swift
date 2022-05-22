// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getTeam = try? newJSONDecoder().decode(GetTeam.self, from: jsonData)

import Foundation

// MARK: - GetTeam
struct TeamSearchStructure: Codable {
    let response: [TeamSearchInformation]
}

struct TeamSearchInformation: Codable, Hashable {
    let team: TeamSearchInformation_Team
    let venue: TeamSearchInformation_Venue?
}

struct TeamSearchInformation_Team: Codable, Hashable {
    let id: Int
    let name: String
    let code: String?
    let country: String?
    let founded: Int?
    let national: Bool
    let logo: String?
}

struct TeamSearchInformation_Venue: Codable, Hashable {
    let id: Int?
    let name: String?
    let address: String?
    let city: String?
    let capacity: Int?
    let surface: String?
    let image: String?
}
