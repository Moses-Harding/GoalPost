//
//  MatchesSectionDataContainer.swift
//  GoalPost
//
//  Created by Moses Harding on 6/6/22.
//

import Foundation
import UIKit

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
            guard let homeTeam = matchData.homeTeam, let awayTeam = matchData.awayTeam else { fatalError("Home team and away team not passed to match \(matchData)") }
            self.name = String(homeTeam.id) + String(awayTeam.id) + DateFormatter().string(from: matchData.timeStamp) + String(matchData.favoriteTeam ? "Favorite" : "")
        case .ad(let adData):
            self.name = adData.name
        }
    }
}

extension MatchesSectionDataContainer: Equatable {
    static func == (lhs: MatchesSectionDataContainer, rhs: MatchesSectionDataContainer) -> Bool {
        return lhs.name == rhs.name && lhs.sectionType == rhs.sectionType && lhs.sectionId == rhs.sectionId
    }
}
