//
//  Enums.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

//MARK: Views

enum ConstraintType {
    case height, width, centerX, centerY, leading, trailing, top, bottom
}

enum ConstraintMethod {
    case scale, edges
}


//MARK: CollectionView

enum MatchesCellType: Codable, Hashable {
    case league(MatchLeagueData)
    case match(MatchData)
    case ad(AdData)
}

enum FavoriteTeamLeague: Int {
    case identifer = 100000000000
}

// MARK: GAD

enum AdViewName: String, Codable, CaseIterable {
    case teamsViewBanner
    case teamInfoViewBanner
    case leaguesViewBanner
    case matchAd1
    case matchAd2
    case matchAd3
    case matchAd4
    case matchAd5
}
