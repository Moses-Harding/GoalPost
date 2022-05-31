//
//  Injury.swift
//  GoalPost
//
//  Created by Moses Harding on 5/29/22.
//

import Foundation


class InjuryObject: Codable {
    
    var team: TeamObject? {
        return Cached.teamDictionary[teamId]
    }
    var player: PlayerObject? {
        return Cached.playerDictionary[playerId]
    }
    var match: MatchObject? {
        return Cached.matchesDictionary[matchId]
    }
    var league: LeagueObject? {
        return Cached.leagueDictionary[leagueId]
    }
    
    var teamId: TeamID
    var playerId: PlayerID
    var matchId: MatchID
    var leagueId: LeagueID
    
    var type: String
    var reason: String
    // Returned on Team Search
    
    var founded: Int?
    
    var id: String
    
    init(_ getInjuriesInformation: GetInjuriesInformation) {
        
        let info = getInjuriesInformation
        
        teamId = info.team.id
        playerId = info.player.id
        leagueId = info.league.id
        matchId = info.fixture.id
        
        if Cached.teamDictionary[teamId] == nil {
            Cached.teamDictionary[teamId] = TeamObject(getInjuriesInformationTeam: info.team)
        }
        
        if Cached.playerDictionary[playerId] == nil { Cached.playerDictionary[playerId] = PlayerObject(getInjuriesInformationPlayer: info.player) }
        if Cached.leagueDictionary[leagueId] == nil { Cached.leagueDictionary[leagueId] = LeagueObject(getInjuriesInformationLeague: info.league) }
        if Cached.matchesDictionary[matchId] == nil { Cached.matchesDictionary[matchId] = MatchObject(getInjuriesInformationFixture: info.fixture) }
        
        self.type = info.player.type
        self.reason = info.player.reason
        
        self.id = "\(matchId)\(playerId)\(reason)"
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
