// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let matchResults = try? newJSONDecoder().decode(MatchResults.self, from: jsonData)

import Foundation

// MARK: - MatchResults
struct GetMatchesStructure: Codable {
    let response: [GetMatchInformation]
}


// MARK: - Response
struct GetMatchInformation: Codable {
    let fixture: GetMatchInformation_Fixture
    let league: GetMatchInformation_League
    let teams: GetMatchInformation_Teams
    let goals: GetMatchInformation_Goals
    let score: GetMatchInformation_Score
    let events: [EventInformation]?
}

// MARK: - Response -  Match
struct GetMatchInformation_Fixture: Codable {
    let id: Int
    let referee: String?
    let timezone: String
    let date: String
    let timestamp: Int
    let periods: GetMatchInformation_Match_Periods
    let venue: GetMatchInformation_Match_Venue
    let status: GetMatchInformation_Match_Status
}

struct GetMatchInformation_Match_Periods: Codable {
    let first: Int?
    let second: Int?
}

struct GetMatchInformation_Match_Venue: Codable {
    let id: Int?
    let name: String?
    let city: String?
}

struct GetMatchInformation_Match_Status: Codable {
    let long: String
    let short: MatchStatusCode
    let elapsed: Int?
}

enum MatchStatusCode: String, Codable {
    case tbd = "TBD" // Time To Be Defined
    case notStarted = "NS" // Not Started
    case firstHalf = "1H" // First Half, Kick Off
    case halfTime = "HT" // Halftime
    case secondHalf = "2H" // Second Half, 2nd Half Started
    case extraTime = "ET" // Extra Time
    case penalties = "P" // Penalty In Progress
    case finished = "FT" // Match Finished
    case finishedAfterExtraTime = "AET" // Match Finished After Extra Time
    case finishedAfterPenalties = "PEN" // Match Finished After Penalty
    case breakTime = "BT" // Break Time (in Extra Time)
    case suspended = "SUSP" // Match Suspended
    case interrupted = "INT" // Match Interrupted
    case postponed = "PST" // Match Postponed
    case cancelled = "CANC" // Match Cancelled
    case abandoned = "ABD" // Match Abandoned
    case technicalLoss = "AWD" // Technical Loss
    case walkOver = "WO" // WalkOver
    case live = "LIVE" // In Progress
}

// MARK: - Response - League
struct GetMatchInformation_League: Codable {
    let id: Int
    let name: String
    let country: String
    let logo: String
    let flag: String?
    let season: Int
    let round: String
}

// MARK: Response - Teams

struct GetMatchInformation_Teams: Codable {
    let home: GetMatchInformation_Teams_Team
    let away: GetMatchInformation_Teams_Team
}

struct GetMatchInformation_Teams_Team: Codable {
    let id: Int
    let name: String
    let logo: String
    let winner: Bool?
}

// MARK: Response - Goals

struct GetMatchInformation_Goals: Codable {
    let home: Int?
    let away: Int?
}

// MARK: Response - Score

struct GetMatchInformation_Score: Codable {
    let halftime: GetMatchInformation_Score_Goals
    let fulltime: GetMatchInformation_Score_Goals
    let extratime: GetMatchInformation_Score_Goals
    let penalty: GetMatchInformation_Score_Goals
}

struct GetMatchInformation_Score_Goals: Codable {
    let home: Int?
    let away: Int?
}

// MARK: Response - Event

struct GetMatchInformation_Event: Codable {
    let time: GetMatchInformation_Event_Time
    let team: GetMatchInformation_Event_Team
    let player: GetMatchInformation_Event_Player
    let assist: GetMatchInformation_Event_Assist
    let type: GetMatchInformation_Event_Type
    let detail: String
    let comments: String?
}

struct GetMatchInformation_Event_Time: Codable {
    let elapsed: Int
    let extra: Int?
}

struct GetMatchInformation_Event_Team: Codable {
    let id: Int
    let name: String
    let logo: String
}

struct GetMatchInformation_Event_Player: Codable {
    let id: Int
    let name: String
}

struct GetMatchInformation_Event_Assist: Codable {
    let id: Int?
    let name: String?
}

enum GetMatchInformation_Event_Type: String, Codable {
    case card = "Card"
    case goal = "Goal"
    case subst = "subst"
    case Var = "Var"
}
