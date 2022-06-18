//
//  Get Players Structure.swift
//  GoalPost
//
//  Created by Moses Harding on 6/13/22.
//

import Foundation

// MARK: - GetPlayers
struct GetSquadStructure: Codable {
    let response: [GetSquadInformation]

}

// MARK: - Response
struct GetSquadInformation: Codable {
    let team: GetSquadInformation_Team
    let players: [GetSquadInformation_Player]
}

// MARK: - Player
struct GetSquadInformation_Player: Codable {
    let id: Int
    let name: String
    let age: Int
    let number: Int?
    let position: GetSquadInformation_Player_Position
    let photo: String
}

struct GetSquadInformation_Team: Codable {
    let id: Int
}

enum GetSquadInformation_Player_Position: String, Codable {
    case attacker = "Attacker"
    case defender = "Defender"
    case goalkeeper = "Goalkeeper"
    case midfielder = "Midfielder"
}
