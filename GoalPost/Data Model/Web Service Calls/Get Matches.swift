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
    

    func getMatchesFor(league: LeagueObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        guard let season = league.currentSeason else {
            print("WARNING - No season available for league \(league.name)")
            return ([MatchUniqueID:MatchObject](), [TeamID:Set<MatchUniqueID>](), [DateString: Set<MatchUniqueID>](), [LeagueID: Set<MatchUniqueID>]())
        }

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(league.id))&season=\(season)"

        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet)
    }
    
    func getLastMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&last=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet)
    }
    
    func getNextMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&next=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet)
    }
    
    func getMatchesFor(team: TeamObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&season=\(await String(team.mostRecentSeason()))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet)
    }
    
    func getMatchesFor(date: Date) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchDate = formatter.string(from: date)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(searchDate)"
        
        note(fileName: "Get Matches", "About to call")
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        note(fileName: "Get Matches", "Data retrieved")
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await convert(data: data)
        note(fileName: "Get Matches", "Data converted")
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet)
    }
    
    func convert(data: Data?) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        // Task.init {
        
        var matchesDictionary = [MatchUniqueID:MatchObject]()
        var matchesByTeam = [TeamID:Set<MatchUniqueID>]()
        var matchesByDateSet = [DateString: Set<MatchUniqueID>]()
        var matchesByLeagueSet = [LeagueID: Set<MatchUniqueID>]()

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        let results: GetMatchesStructure = try JSONDecoder().decode(GetMatchesStructure.self, from: data)
        
        note(fileName: "Get Matches", "Number of results - \(results.response.count)")
        
        let favoriteLeagues = await Cached.data.favoriteLeagues
        
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
            if favoriteLeagues.keys.contains(leagueId) {
                matchesByDateSet.add(matchUniqueId, toSetWithKey: matchDate.asKey)
            }
            /*
            if await Cached.data.favoriteLeagues.keys.contains(leagueId) {
                
                matchesByDateSet.add(matchUniqueId, toSetWithKey: matchDate.asKey)
            }
             */
            
            // Add to dictionary of all matches
            matchesDictionary[matchUniqueId] = matchData
            
            // Add to set of matches
            
            matchesByLeagueSet.add(matchUniqueId, toSetWithKey: leagueId)
            matchesByTeam.add(matchUniqueId, toSetWithKey: homeTeamId)
            matchesByTeam.add(matchUniqueId, toSetWithKey: awayTeamId)
        }
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet)
        //}
    }
}
