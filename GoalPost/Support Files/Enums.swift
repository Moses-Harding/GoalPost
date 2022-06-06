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
    case league(LeagueObject)
    case match(MatchObject)
    case ad(AdObject)
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

// For Team Data Object

enum TeamDataObjectType: String {
    case match = "Matches"
    case injury = "Injuries and Absences"
    case transfer = "Transfers"
    // case squad = "Squad"
}


enum ElementKind: String {
    case titleElementKind = "title-element-kind"
    case titleSupplementaryView = "title-supplementary-reuse-identifier"
}

// Errors

enum WebServiceCallErrors: Error {
    case dataNotPassedToConversionFunction
    case noDataRetrieved
    case resultsNotDecoded
    case elementNotFoundInLookupDictionary
}
