//
//  LeagueDateObject.swift
//  GoalPost
//
//  Created by Moses Harding on 9/2/22.
//

import Foundation
        

struct LeagueDateObject: Hashable {
    
    var date: Date
    var dateString: String {
        return date.dayOfWeekFormat()
    }
    
    var gamesCount: Int {
        return matchIds.count
    }
    var gamesCountString: String {
        return "\(matchIds.count) match\(matchIds.count > 0 ? "es" : "")"
    }
    
    var matchIds = Set<MatchUniqueID>()
    var matchIdsString: String {
        var string = ""
        for id in matchIds {
            string += "\(QuickCache.helper.matchesDictionary[id]?.marquee ?? "NOT FOUND")\n"
        }
        return string
    }
}
