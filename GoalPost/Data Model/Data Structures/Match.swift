//
//  Match.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

class MatchObject: Codable {
    
    var id: MatchID

    var timeStamp: Date
    var timezone: String?
    var timeElapsed: Int?
    
    var homeTeam: TeamObject? {
        if let id = homeTeamId {
            return Cached.teamDictionary[id]
        } else {
            return nil
        }
    }
    var homeTeamId: TeamID?
    var homeTeamScore: Int?
    
    var awayTeam: TeamObject? {
        if let id = awayTeamId {
            return Cached.teamDictionary[id]
        } else {
            return nil
        }
    }
    var awayTeamId: TeamID?
    var awayTeamScore: Int?
    
    var status: MatchStatusCode
    
    var favoriteTeam: Bool

    var league: LeagueObject? {
        if let id = leagueId {
            return Cached.leagueDictionary[id]
        } else {
            return nil
        }
    }
    var leagueId: LeagueID?
    
    init(id: MatchID, favoriteTeam: Bool = false, timeStamp: Date, timeElapsed: Int? = nil, status: MatchStatusCode? = nil, leagueId: LeagueID? = nil, homeTeamId: TeamID? = nil, awayTeamId: TeamID? = nil, homeTeamScore: Int? = nil, awayTeamScore: Int? = nil) {
        
        self.id = id
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
        
        Cached.teamDictionary.addIfNoneExists(TeamObject(getMatchInfoTeam: getMatchesStructure.teams.home), key: getMatchesStructure.teams.home.id)
        Cached.teamDictionary.addIfNoneExists(TeamObject(getMatchInfoTeam: getMatchesStructure.teams.away), key: getMatchesStructure.teams.away.id)
        Cached.leagueDictionary.addIfNoneExists(LeagueObject(getMatchInformationLeague: getMatchesStructure.league), key: getMatchesStructure.league.id)
    }
    
    convenience init(getInjuriesInformationFixture fixture: GetInjuriesInformation_Fixture) {
        self.init(id: fixture.id, timeStamp: Date(timeIntervalSince1970: TimeInterval(fixture.timestamp)))
    }
}

extension MatchObject: Hashable {
    static func == (lhs: MatchObject, rhs: MatchObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Section Data Container

struct MatchesSectionDataContainer: Codable, Hashable {
    
    static var countOfMatches = 0
    var sectionType: MatchesCellType
    var sectionId: Int = countOfMatches + 1
    var name: String
    
    init(_ cellType: MatchesCellType) {
        MatchesSectionDataContainer.countOfMatches += 1
        self.sectionType = cellType
        switch sectionType {
        case .league(let matchLeagueData):
            self.name = matchLeagueData.name
        case .match(let matchData):
            guard let homeTeam = matchData.homeTeam, let awayTeam = matchData.awayTeam else { fatalError("Home team and away team not passed to match \(matchData)") }
            self.name = String(homeTeam.id) + String(awayTeam.id) + DateFormatter().string(from: matchData.timeStamp)
        case .ad(let adData):
            self.name = adData.name
        }
    }
}
