//
//  Injury.swift
//  GoalPost
//
//  Created by Moses Harding on 5/29/22.
//

import Foundation

/*
 NOTE: An injuryObject is just a collection of Ids. A custom id is constructed (ordered by match/player/reason for easy sorting). There is some basic information passed from the "GetInjuries" call, so if a given player, league, or match doesn't already exist, it's added to the cache; otherwise, the more robust version of the object is returned.
 */

class InjuryObject: Codable {
    
    func team() async -> TeamObject? {
        return await Cached.data.teamDictionary(teamId)
    }
    func player() async -> PlayerObject? {
        return await Cached.data.playerDictionary(playerId)
    }
    func league() async -> LeagueObject? {
        return await Cached.data.leagueDictionary(leagueId)
    }
    
    var teamId: TeamID
    var playerId: PlayerID
    var matchId: MatchUniqueID
    var leagueId: LeagueID
    
    var type: String
    var reason: String
    var date: Date
    
    var id: String
    
    init(_ getInjuriesInformation: GetInjuriesInformation) {
        
        let info = getInjuriesInformation
        
        teamId = info.team.id
        playerId = info.player.id
        leagueId = info.league.id
        matchId = MatchObject.getUniqueID(id: info.fixture.id, timestamp: info.fixture.timestamp)
        date = Date(timeIntervalSince1970: TimeInterval(info.fixture.timestamp))

         
        self.type = info.player.type
        self.reason = info.player.reason
        
        self.id = "\(info.fixture.timestamp)\(matchId)\(playerId)\(reason)"
        
        
        Task.init {
            await Cached.data.playerDictionaryAddIfNoneExists(PlayerObject(getInjuriesInformationPlayer: info.player), key: playerId)
            await Cached.data.leagueDictionaryAddIfNoneExists(LeagueObject(getInjuriesInformationLeague: info.league), key: leagueId)
        }
    }
}

extension InjuryObject: Hashable {
    static func == (lhs: InjuryObject, rhs: InjuryObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
