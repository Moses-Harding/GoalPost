//
//  TeamDataObject.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

class ObjectContainer {
    
    static var universalCount = 0
    
    var type: TeamDataObjectType
    
    func injury() async -> InjuryObject? {
        guard let id = injuryId else { return nil }
        return await Cached.data.injuryDictionary(id)
    }
    
    func match() async -> MatchObject? {
        guard let id = matchId else { return nil }
        return await Cached.data.matchesDictionary(id)
    }
    
    func transfer() async -> TransferObject? {
        guard let id = transferId else { return nil }
        return await Cached.data.transferDictionary(id)
    }
    
    func player() async -> PlayerObject? {
        guard let id = playerId else { return nil }
        return await Cached.data.playerDictionary(id)
    }
    
    func league() async -> LeagueObject? {
        guard let id = leagueId else { return nil }
        return await Cached.data.leagueDictionary(id)
    }

    var injuryId: InjuryID?
    var leagueId: LeagueID?
    var matchId: MatchUniqueID?
    var transferId: TransferID?
    var playerId: PlayerID?
    
    var favoriteLeague = false
    
    var id: Int
    var loading: Bool = false
    
    private init(type: TeamDataObjectType) {
        self.type = type
        
        ObjectContainer.universalCount += 1
        id = ObjectContainer.universalCount
    }
    
    convenience init(matchId: MatchUniqueID) {
        self.init(type: .match)
        self.matchId = matchId
    }
    
    convenience init(injuryId: InjuryID) {
        self.init(type: .injury)
        self.injuryId = injuryId
    }
    
    
    convenience init(transferId: TransferID) {
        self.init(type: .transfer)
        self.transferId = transferId
    }
    
    convenience init(playerId: PlayerID) {
        self.init(type: .player)
        self.playerId = playerId
    }
    
    convenience init(leagueId: LeagueID) {
        self.init(type: .league)
        self.leagueId = leagueId
    }
    
    convenience init(favoriteLeague: Bool) {
        self.init(type: .league)
        self.favoriteLeague = favoriteLeague
    }
    
    convenience init(type: TeamDataObjectType, loading: Bool) {
        self.init(type: type)
        self.loading = true
    }
}

extension ObjectContainer: Hashable {
    static func == (lhs: ObjectContainer, rhs: ObjectContainer) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
