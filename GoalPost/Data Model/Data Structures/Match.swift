//
//  Match.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation



// MARK: Structures used in MatchesDataContainer

struct MatchData: Codable, Hashable {
    var homeTeam: MatchTeamData
    var awayTeam: MatchTeamData
    var status: MatchStatusCode
    var timeElapsed: Int?
    var timeStamp: Date
    var favoriteTeam: Bool
    var id: Int
}

struct MatchLeagueData: Codable, Hashable {
    var name: String
    var country: String
    var id: Int
    var matches: [Int:MatchData]
}

struct MatchTeamData: Codable, Hashable {
    var name: String
    var id: Int
    var logoURL: String
    var score: Int?
}

// MARK: Section Data Container

struct MatchesSectionDataContainer: Codable, Hashable {
    
    static var countOfMatches = 0
    var sectionType: MatchesCellType
    var sectionId: Int = countOfMatches + 1
    var name: String
    
    init(_ cellType: MatchesCellType) {
        MatchesSectionDataContainer.countOfMatches += 1
        self.sectionType = cellType
        switch sectionType {
        case .league(let matchLeagueData):
            self.name = matchLeagueData.name
        case .match(let matchData):
            self.name = String(matchData.homeTeam.id) + String(matchData.awayTeam.id) + DateFormatter().string(from: matchData.timeStamp)
        case .ad(let adData):
            self.name = adData.name
        }
    }
}
