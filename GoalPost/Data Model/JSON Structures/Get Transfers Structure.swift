//
//  Get Transfers.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation

struct GetTransfersStructure: Codable {
    //let getTransfersGet: String
    //let parameters: Parameters
    //let errors: [Any?]
    //let results: Int
    //let paging: Paging
    let response: [GetTransfersInformation]
}

// MARK: - Response
struct GetTransfersInformation: Codable {
    let player: GetTransfersInformation_Player
    //let update: Date
    let transfers: [GetTransfersInformation_Transfer]
}

// MARK: - Player
struct GetTransfersInformation_Player: Codable {
    let id: Int
    let name: String?
}

// MARK: - Transfer
struct GetTransfersInformation_Transfer: Codable {
    let date: String
    let type: String?
    let teams: GetTransfersInformation_Transfer_Teams
}

// MARK: - Teams
struct GetTransfersInformation_Transfer_Teams: Codable {
    let teamsIn: GetTransfersInformation_Transfer_Teams_Team?
    let teamsOut: GetTransfersInformation_Transfer_Teams_Team?
    
    enum CodingKeys: String, CodingKey {
        case teamsIn = "in"
        case teamsOut = "out"
    }
}

// MARK: - In
struct GetTransfersInformation_Transfer_Teams_Team: Codable  {
    let id: Int?
    let name: String?
    let logo: String?
}
