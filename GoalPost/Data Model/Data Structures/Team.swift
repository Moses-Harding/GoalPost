//
//  Team.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation



// MARK: Structures used in TeamSearchDataContainer

struct TeamSearchData: Codable, Hashable {
    let id: Int
    let name: String
    let code: String?
    let country: String?
    let founded: Int?
    let national: Bool
    let logo: String?
    let venue: TeamSearchVenue
}

struct TeamSearchVenue: Codable, Hashable {
    let id: Int?
    let name: String?
    let address: String?
    let city: String?
    let capacity: Int?
    let surface: String?
    let image: String?
}
