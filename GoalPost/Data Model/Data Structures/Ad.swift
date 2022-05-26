//
//  Ad.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation


// MARK: Ad Data Contianer

struct AdData: Codable, Hashable {
    
    static var countOfAds = 0
    var name: String
    var adViewName: AdViewName
    var viewWidth: Float
    
    init(adViewName: AdViewName, viewWidth: Float) {
        self.adViewName = adViewName
        self.name = "Ad " + String(AdData.countOfAds) + " - " + adViewName.rawValue
        self.viewWidth = viewWidth
        AdData.countOfAds += 1
    }
}
