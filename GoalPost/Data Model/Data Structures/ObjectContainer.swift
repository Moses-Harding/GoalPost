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
    
    var match: MatchObject? {
        guard let id = matchId else { return nil }
        return QuickCache.helper.matchesDictionary[id]
    }
    
    func transfer() async -> TransferObject? {
        guard let id = transferId else { return nil }
        return await Cached.data.transferDictionary(id)
    }
    
    func player() async -> PlayerObject? {
        guard let id = playerId else { return nil }
        return await Cached.data.playerDictionary(id)
    }
    
    var league: LeagueObject? {
        guard let id = leagueId else { return nil }
        return QuickCache.helper.leagueDictionary[id]
    }

    var injuryId: InjuryID?
    var leagueId: LeagueID?
    var matchId: MatchID?
    var transferId: TransferID?
    var playerId: PlayerID?
    
    var favoriteLeague = false
    
    var id: String!
    var loading: Bool = false
    
    var name: String!
    
    var showSeperator = true
    
    private init(type: TeamDataObjectType) {
        self.type = type
    }
    
    convenience init(matchId: MatchID) {
        self.init(type: .match)
        self.name = String(matchId)
        self.matchId = matchId
        self.id = String(matchId)
    }
    
    convenience init(injuryId: InjuryID) {
        self.init(type: .injury)
        self.name = String(injuryId)
        self.injuryId = injuryId
        self.id = injuryId
    }
    
    
    convenience init(transferId: TransferID) {
        self.init(type: .transfer)
        self.name = String(transferId)
        self.transferId = transferId
        self.id = transferId
    }
    
    convenience init(playerId: PlayerID) {
        self.init(type: .player)
        self.name = String(playerId)
        self.playerId = playerId
        self.id = String(playerId)
    }
    
    convenience init(leagueId: LeagueID, name: String) {
        self.init(type: .league)
        self.name = name
        self.leagueId = leagueId
        self.id = String(leagueId)
    }
    
    convenience init(favoriteLeague: Bool) {
        self.init(type: .league)
        self.name = "** My teams"
        self.favoriteLeague = favoriteLeague
        self.id = "** My teams"
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

extension ObjectContainer: CustomStringConvertible {
    var description: String {
        return "\(self.type) - \(String(self.id))"
    }
}
