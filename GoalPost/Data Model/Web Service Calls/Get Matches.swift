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
    

    func getMatchesFor(league: LeagueObject) async throws -> (MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary) {
        
        guard let season = league.currentSeason else {
            print("WARNING - No season available for league \(league.name)")
            return (MatchesDictionary(), MatchesByTeamDictionary(), MatchesByDateDictionary(), MatchesByLeagueDictionary(), MatchIdDictionary())
        }

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(league.id))&season=\(season)"

        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary)
    }
    
    func getLastMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> (MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary){
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&last=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary)
    }
    
    func getNextMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> (MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&next=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary)
    }
    
    func getMatchesFor(team: TeamObject) async throws -> (MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&season=\(await String(team.mostRecentSeason()))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary)
    }
    
    func getMatchesFor(date: Date) async throws -> (MatchesDictionary, MatchesByDateDictionary, MatchIdDictionary) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchDate = formatter.string(from: date)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(searchDate)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByDateDictionary, matchIdDictionary) = try await convertDate(data: data)
        
        return (matchesDictionary, matchesByDateDictionary, matchIdDictionary)
    }
    
    func getMatchesFor(matchIds: [Int]) async throws -> (MatchesDictionary, MatchesByDateDictionary, MatchIdDictionary) {

        var searchString = ""
        
        for x in 0 ..< matchIds.count {
            if x != 0 {
                searchString += "-"
            }
            searchString += "\(String(matchIds[x]))"
        }
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?ids=\(searchString)"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByDateDictionary, matchIdDictionary) = try await convertDate(data: data)
        
        return (matchesDictionary, matchesByDateDictionary, matchIdDictionary)
    }
    
    func getLiveMatches() async throws -> (MatchesDictionary, MatchesByDateDictionary, MatchIdDictionary) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?live=all"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByDateDictionary, matchIdDictionary) = try await convertDate(data: data)
        
        return (matchesDictionary, matchesByDateDictionary, matchIdDictionary)
    }
    
    
    func convert(data: Data?) async throws -> (MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary) {

        var matchesDictionary: MatchesDictionary = [:]
        var matchesByTeamDictionary: MatchesByTeamDictionary = [:]
        var matchesByDateDictionary: MatchesByDateDictionary = [:]
        var matchesByLeagueDictionary: MatchesByLeagueDictionary = [:]
        var matchIdDictionary: MatchIdDictionary = [:]

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        let results: GetMatchesStructure = try JSONDecoder().decode(GetMatchesStructure.self, from: data)
        
        note(fileName: "Get Matches", "Number of results - \(results.response.count)")
        
        let favoriteLeagues = await Cached.data.favoriteLeaguesDictionary
        let favoriteTeams = await Cached.data.favoriteTeamsDictionary
        
        for result in results.response {

            // Get league Details
            let leagueId = result.league.id
            let matchId = result.fixture.id
            let matchUniqueId = MatchObject.getUniqueID(id: matchId, timestamp: result.fixture.timestamp)
            
            let homeTeamId = result.teams.home.id
            let awayTeamId = result.teams.away.id
            
            if favoriteLeagues.keys.contains(leagueId) || favoriteTeams.keys.contains(homeTeamId) ||
                favoriteTeams.keys.contains(awayTeamId) {
                
                let matchDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))

                let matchData = MatchObject(getMatchesStructure: result, favoriteTeam: false)

                // Add if it's in a favorite league
                
                matchesByDateDictionary.add(matchId, toSetWithKey: matchDate.asKey)
                
                if favoriteTeams.keys.contains(homeTeamId) || favoriteTeams.keys.contains(awayTeamId) {
                    print("Adding \(matchUniqueId)")
                    matchesByLeagueDictionary.add(matchId, toSetWithKey: DefaultIdentifier.favoriteTeam.rawValue)
                }
                
                // Add to dictionary of all matches
                matchesDictionary[matchId] = matchData
                
                // Update the matchIdDictionary (for sorting)
                matchIdDictionary[matchId] = matchUniqueId
                
                // Add to set of matches
                matchesByLeagueDictionary.add(matchId, toSetWithKey: leagueId)
                matchesByTeamDictionary.add(matchId, toSetWithKey: homeTeamId)
                matchesByTeamDictionary.add(matchId, toSetWithKey: awayTeamId)
            } else {
                continue
            }
        }
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary)
    }
    
    func convertDate(data: Data?) async throws -> (MatchesDictionary, MatchesByDateDictionary, MatchIdDictionary) {
        
        var matchesDictionary: MatchesDictionary = [:]
        var matchesByDateDictionary: MatchesByDateDictionary = [:]
        var matchIdDictionary: MatchIdDictionary = [:]

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        let results: GetMatchesStructure = try JSONDecoder().decode(GetMatchesStructure.self, from: data)
        
        let favoriteLeagues = await Cached.data.favoriteLeaguesDictionary
        let favoriteTeams = await Cached.data.favoriteTeamsDictionary
        
        for result in results.response {

            // Get league Details
            let leagueId = result.league.id
            let matchId = result.fixture.id
            let matchUniqueId = MatchObject.getUniqueID(id: matchId, timestamp: result.fixture.timestamp)
            
            let homeTeamId = result.teams.home.id
            let awayTeamId = result.teams.away.id
            
            if favoriteLeagues.keys.contains(leagueId) || favoriteTeams.keys.contains(homeTeamId) || favoriteTeams.keys.contains(awayTeamId) {
                
                let matchDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))

                let matchData = MatchObject(getMatchesStructure: result, favoriteTeam: false)
                
                
                // print("GetMatches - Adding \(matchData.marquee) - \(Date.now.timeStamp)")

                // Add if it's in a favorite league
                matchesByDateDictionary.add(matchId, toSetWithKey: matchDate.asKey)
                
                // Add to dictionary of all matches
                matchesDictionary[matchId] = matchData
                
                // Update the matchIdDictionary (for sorting)
                matchIdDictionary[matchId] = matchUniqueId
            } else {
                continue
            }
        }
        
        //print("Get Matches - Convert Date - Data Converted - \(results.response.count) - \(Date.now.timeStamp)")
        return (matchesDictionary, matchesByDateDictionary, matchIdDictionary)
    }
}
