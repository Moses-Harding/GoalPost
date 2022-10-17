//
//  EventObject.swift
//  GoalPost
//
//  Created by Moses Harding on 10/14/22.
//

import Foundation

class EventObject: Codable {
    
    let playerId: Int?
    let playerName: String?
    
    let assistingPlayerId: Int?
    let assistingPlayerName: String?
    
    let teamId: Int
    let teamName: String
    
    let timeElapsed: Int
    let extraTimeElapsed: Int?
    
    let eventType: EventInformation_Type
    let eventDetail: String
    
    let comments: String?
    
    var imageName: String?
    
    var id: String
    
    init(_ event: EventInformation) {
        

        playerId = event.player.id
        playerName = event.player.name
        
        assistingPlayerId = event.assist.id
        assistingPlayerName = event.assist.name
        
        teamId = event.team.id
        teamName = event.team.name
        
        timeElapsed = event.time.elapsed
        extraTimeElapsed = event.time.extra
        
        eventType = event.type
        eventDetail = event.detail
        
        comments = event.comments
        
        id = "\(teamId)\(timeElapsed)\(eventDetail)"
    }
    
    func selectImage() {
        
        switch eventType {
        case .card:
            if eventDetail == "Red Card" {
                imageName = "Red Card"
            } else if eventDetail == "Yellow Card" {
                imageName = "Yellow Card"
            }
        case .goal:
            imageName = "Goal"
        case .subst:
            imageName = "Hublot Clock"
        case .Var:
            imageName = "VAR"
        }
    }
}

extension EventObject: Hashable {
    static func == (lhs: EventObject, rhs: EventObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
