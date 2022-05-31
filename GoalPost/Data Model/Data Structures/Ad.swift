//
//  Ad.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation


// MARK: Ad Data Contianer

struct AdObject: Codable, Hashable {
    
    static var countOfAds = 0
    var name: String
    var adViewName: AdViewName
    
    init(adViewName: AdViewName) {
        self.adViewName = adViewName
        self.name = "Ad " + String(AdObject.countOfAds) + " - " + adViewName.rawValue
        AdObject.countOfAds += 1
    }
}
