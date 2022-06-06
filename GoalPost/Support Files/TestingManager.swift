//
//  TestingManager.swift
//  GoalPost
//
//  Created by Moses Harding on 5/4/22.
//

import Foundation

struct Testing {
    static var manager = Testing()
    
    var verboseWebServiceCalls = false
    
    var getMatchesForFavoriteLeagues = true
    var getLiveTestData = true
    
    var disableAds = false
}
