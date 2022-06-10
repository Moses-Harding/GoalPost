//
//  Live Match Data.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation

//https://rapidapi.com/api-sports/api/api-football/

// The container that stores current matches

class GetMatches {
    
    static var helper = GetMatches()
    

    func getMatchesFor(league: LeagueObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject]) {
        
        guard let season = league.currentSeason else {
            print("WARNING - No season available for league \(league.name)")
            return ([MatchUniqueID:MatchObject](), [TeamID:Set<MatchUniqueID>](), [DateString: Set<MatchUniqueID>](), [LeagueID: Set<MatchUniqueID>](), [DateString: Set<MatchUniqueID>](), [MatchUniqueID:MatchObject]())
        }

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(league.id))&season=\(season)"

        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func getLastMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&last=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func getNextMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&next=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func getMatchesFor(team: TeamObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&season=\(String(team.mostRecentSeason))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func getMatchesFor(date: Date) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject]) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchDate = formatter.string(from: date)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(searchDate)"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func convert(data: Data?) throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject]) {
        
        var matchesDictionary = [MatchUniqueID:MatchObject]()
        var matchesByTeam = [TeamID:Set<MatchUniqueID>]()
        var matchesByDateSet = [DateString: Set<MatchUniqueID>]()
        var matchesByLeagueSet = [LeagueID: Set<MatchUniqueID>]()
        var favoriteMatchesByDateSet = [DateString: Set<MatchUniqueID>]()
        var favoriteMatchesDictionary = [MatchUniqueID:MatchObject]()

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        let results: GetMatchesStructure = try JSONDecoder().decode(GetMatchesStructure.self, from: data)
        
        for result in results.response {
            
            // Get league Details
            let leagueId = result.league.id
            let matchId = result.fixture.id
            let matchUniqueId = MatchObject.getUniqueID(id: matchId, timestamp: result.fixture.timestamp)
            let homeTeamId = result.teams.home.id
            let awayTeamId = result.teams.away.id
            
            let matchDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))

            let matchData = MatchObject(getMatchesStructure: result, favoriteTeam: false)

            // Add if it's in a favorite league
            if Cached.favoriteLeagues.keys.contains(leagueId) {
                
                matchesByDateSet.add(matchUniqueId, toSetWithKey: matchDate.asKey)
            }
            
            // Add if it's a favorite team
            if Cached.favoriteTeams.keys.contains(homeTeamId) || Cached.favoriteTeams.keys.contains(awayTeamId) {
                
                let favoriteMatchId = DefaultIdentifier.favoriteTeam.rawValue + matchId
                let favoriteMatchUniqueID = MatchObject.getUniqueID(id: favoriteMatchId, timestamp: result.fixture.timestamp)
                let favoriteMatchData = MatchObject(getMatchesStructure: result, favoriteTeam: true)
                
                favoriteMatchesByDateSet.add(favoriteMatchUniqueID, toSetWithKey: matchDate.asKey)
                favoriteMatchesDictionary[favoriteMatchUniqueID] = favoriteMatchData
            }
            
            // Add to dictionary of all matches
            matchesDictionary[matchUniqueId] = matchData
            
            // Add to set of matches
            
            matchesByLeagueSet.add(matchUniqueId, toSetWithKey: leagueId)
            matchesByTeam.add(matchUniqueId, toSetWithKey: homeTeamId)
            matchesByTeam.add(matchUniqueId, toSetWithKey: awayTeamId)
        }
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
}
