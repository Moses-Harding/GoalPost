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


enum Section {
    case main
}

enum MatchesCellType: Codable, Hashable {
    case league(LeagueObject)
    case match(MatchObject)
    case ad(AdObject)
}

enum MatchesViewCollectionSectionType {
    case league
    case ad
}

enum DefaultIdentifier: Int {
    case favoriteTeam = 10000000000000
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
    case injury = "Injuries and Absences"
    case league = "League"
    case match = "Matches"
    case player = "Squad"
    case transfer = "Transfers"
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
