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
    
    var disableAds = true
}

func note(fileName: String, _ message: String) {
    print("\n[N O T A T I O N]\n-------------------------------------")
    print("--- Note called in \(fileName) ---")
    print(message)
    print("-------------------------------------\n[E N D_N O T A T I O N]\n")
}
