//
//  Match.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

class MatchObject: Codable {
    
    var id: MatchID
    var uniqueID: MatchUniqueID
    
    var timeStamp: Date
    var timezone: String?
    var timeElapsed: Int?
    
    func homeTeam() async -> TeamObject? {
        return await Cached.data.teamDictionary(homeTeamId)
    }
    var homeTeamId: TeamID
    var homeTeamScore: Int?
    
    func awayTeam() async -> TeamObject? {
        return await Cached.data.teamDictionary(awayTeamId)
    }
    var awayTeamId: TeamID
    var awayTeamScore: Int?
    
    var status: MatchStatusCode
    
    var favoriteTeam: Bool
    
    func league() async -> LeagueObject? {
        if let id = leagueId {
            return await Cached.data.leagueDictionary(id)
        } else {
            return nil
        }
    }
    var leagueId: LeagueID?
    
    init(id: MatchID, favoriteTeam: Bool = false, timeStamp: Date, timeElapsed: Int? = nil, status: MatchStatusCode? = nil, leagueId: LeagueID? = nil, homeTeamId: TeamID, awayTeamId: TeamID, homeTeamScore: Int? = nil, awayTeamScore: Int? = nil) {
        
        self.id = id
        self.uniqueID = MatchObject.getUniqueID(id: id, timestamp: timeStamp)
        self.favoriteTeam = favoriteTeam
        self.timeStamp = timeStamp
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.status = status ?? .notStarted
        self.leagueId = leagueId
    }
    
    convenience init(getMatchesStructure: GetMatchInformation, favoriteTeam: Bool) {
        
        let matchDate = Date(timeIntervalSince1970: TimeInterval(getMatchesStructure.fixture.timestamp))
        let timeElapsed = getMatchesStructure.fixture.status.elapsed
        let status = getMatchesStructure.fixture.status.short
        let matchID = getMatchesStructure.fixture.id
        
        self.init(id: matchID, favoriteTeam: favoriteTeam, timeStamp: matchDate, timeElapsed: timeElapsed, status: status, leagueId: getMatchesStructure.league.id, homeTeamId: getMatchesStructure.teams.home.id, awayTeamId: getMatchesStructure.teams.away.id, homeTeamScore: getMatchesStructure.goals.home, awayTeamScore: getMatchesStructure.goals.away)
        
        // If there are no copies of the home / away teams in the dictionary, add them for each search
        
        let homeTeam = TeamObject(getMatchInfoTeam: getMatchesStructure.teams.home)
        let awayTeam = TeamObject(getMatchInfoTeam: getMatchesStructure.teams.away)
        
        Task.init {
            await Cached.data.teamDictionaryAddIfNoneExists(homeTeam, key: getMatchesStructure.teams.home.id)
            await Cached.data.teamDictionaryAddIfNoneExists(awayTeam, key: getMatchesStructure.teams.away.id)
            
            await Cached.data.leagueDictionaryAddIfNoneExists(LeagueObject(getMatchInformationLeague: getMatchesStructure.league), key: getMatchesStructure.league.id)
        }
    }
}

extension MatchObject {
    static func getUniqueID(id: Int, timestamp: Int) -> MatchUniqueID {
        return "\(timestamp)\(id)"
    }
    
    static func getUniqueID(id: Int, timestamp: Date) -> MatchUniqueID {
        return "\(timestamp.timeIntervalSince1970)\(id)"
    }
}

extension MatchObject: Hashable {
    static func == (lhs: MatchObject, rhs: MatchObject) -> Bool {
        return lhs.id == rhs.id && lhs.favoriteTeam == rhs.favoriteTeam
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(favoriteTeam)
    }
}

extension MatchObject: CustomStringConvertible {
    var description: String {
        return "\(self.timeStamp.formatted(date: .numeric, time: .omitted)) - \(self.uniqueID)"
    }
}
