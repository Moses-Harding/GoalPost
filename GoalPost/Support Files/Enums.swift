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
    case fixture(MatchData)
    case ad(AdData)
}

enum FavoriteTeamLeague: Int {
    case identifer = 100000000000
}
