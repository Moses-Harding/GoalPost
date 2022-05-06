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

enum ListItem: Hashable {
    case league(LeagueData)
    case fixture(FixtureData)
}
