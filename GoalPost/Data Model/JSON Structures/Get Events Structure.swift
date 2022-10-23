//
//  Match Events Structure.swift
//  GoalPost
//
//  Created by Moses Harding on 10/13/22.
//

import Foundation

// MARK: - GetEvents
struct GetEventsStructure: Codable {
    let response: [EventInformation]
}


// MARK: - Response
struct EventInformation: Codable {
    let time: EventInformation_Time
    let team: EventInformation_Team
    let player: EventInformation_Player
    let assist: EventInformation_Assist
    let type: EventInformation_Type
    let detail: String
    let comments: String?

}

// MARK: - Assist
struct EventInformation_Assist: Codable {
    let id: Int?
    let name: String?
}

// MARK: - Player
struct EventInformation_Player: Codable {
    let id: Int
    let name: String
}

// MARK: - Team
struct EventInformation_Team: Codable {
    let id: Int
    let name: String
    let logo: String
}

// MARK: - Time
struct EventInformation_Time: Codable {
    let elapsed: Int
    let extra: Int?
}

enum EventInformation_Type: String, Codable {
    case card = "Card"
    case goal = "Goal"
    case subst = "subst"
    case Var = "Var"
}

enum EventInformation_Detail: String, Codable {
    case goalCancelled = "Goal cancelled"
    case goalDisallowed = "Goal Disallowed - Foul"
    case missedPenalty = "Missed Penalty"
    case normalGoal = "Normal Goal"
    case ownGoal = "Own Goal"
    case penalty = "Penalty"
    case penaltyConfirmed = "Penalty confirmed"
    case redCard = "Red Card"
    case substitution1 = "Substitution 1"
    case substitution2 = "Substitution 2"
    case substitution3 = "Substitution 3"
    case substitution4 = "Substitution 4"
    case substitution5 = "Substitution 5"
    case substitution6 = "Substitution 6"
    case substitution7 = "Substitution 7"
    case substitution8 = "Substitution 8"
    case substitution9 = "Substitution 9"
    case substitution10 = "Substitution 10"
    case yellowCard = "Yellow Card"
}
