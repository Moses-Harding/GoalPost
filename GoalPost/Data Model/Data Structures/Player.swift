//
//  Player.swift
//  GoalPost
//
//  Created by Moses Harding on 5/29/22.
//

import Foundation
import UIKit

struct PlayerStatistics: Codable {
    var team: TeamID
    var league: LeagueID
    
    var appearences: Int
    var lineups: Int
    var minutes: Int
    var number: Int?
    var position: String
    var rating: String
    var captain: Bool
}

class PlayerObject: Codable {
    
    var id: PlayerID
    var name: String
    var firstName: String?
    var lastName: String?
    var age: Int?
    var birthDay: Date?
    var birthPlace: String?
    var nationality: String?
    var height: String?
    var weight: String?
    var injured: Bool?
    var photo: String?
    
    var teams = [TeamID]()
    
    init(id: PlayerID, name: String, photo: String?) {
        self.id = id
        self.name = name
        self.photo = photo
    }
    
    convenience init(getInjuriesInformationPlayer player: GetInjuriesInformation_Player) {
        self.init(id: player.id, name: player.name, photo: player.photo)
    }
}
