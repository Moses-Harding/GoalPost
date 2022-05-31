//
//  TeamDataObject.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

class TeamDataObject {
    
    static var universalCount = 0
    
    var type: TeamDataObjectType
    
    var injury: InjuryObject? {
        guard let id = injuryId else { return nil }
        return Cached.injuryDictionary[id]
    }
    
    var match: MatchObject? {
        guard let id = matchId else { return nil }
        return Cached.matchesDictionary[id]
    }

    var injuryId: InjuryID?
    var matchId: MatchID?
    
    var id: Int
    
    private init(type: TeamDataObjectType) {
        self.type = type
        
        TeamDataObject.universalCount += 1
        id = TeamDataObject.universalCount
    }
    
    convenience init(matchId: MatchID) {
        self.init(type: .match)
        self.matchId = matchId
    }
    
    convenience init(injuryId: InjuryID) {
        self.init(type: .injury)
        self.injuryId = injuryId
    }
}



extension TeamDataObject: Hashable {
    static func == (lhs: TeamDataObject, rhs: TeamDataObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
