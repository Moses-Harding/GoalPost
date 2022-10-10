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
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary)
    }
    
    func getLastMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&last=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary)
    }
    
    func getNextMatchesFor(team: TeamObject, numberOfMatches: Int) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&next=\(String(numberOfMatches))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary)
    }
    
    func getMatchesFor(team: TeamObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&season=\(await String(team.mostRecentSeason()))"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await convert(data: data)
        
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary)
    }
    
    func getMatchesFor(date: Date) async throws -> ([MatchUniqueID:MatchObject], [DateString: Set<MatchUniqueID>]) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchDate = formatter.string(from: date)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(searchDate)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByDateDictionary) = try await convertDate(data: data)
        
        return (matchesDictionary, matchesByDateDictionary)
    }
    
    func getMatchesFor(matchIds: [Int]) async throws -> ([MatchUniqueID:MatchObject], [DateString: Set<MatchUniqueID>]) {

        var searchString = ""
        
        for x in 0 ..< matchIds.count {
            if x != 0 {
                searchString += "-"
            }
            searchString += "\(String(matchIds[x]))"
        }
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?ids=\(searchString)"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByDateDictionary) = try await convertDate(data: data)
        
        return (matchesDictionary, matchesByDateDictionary)
    }
    
    func getLiveMatches() async throws -> ([MatchUniqueID:MatchObject], [DateString: Set<MatchUniqueID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?live=all"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByDateDictionary) = try await convertDate(data: data)
        
        return (matchesDictionary, matchesByDateDictionary)
    }
    
    
    func convert(data: Data?) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>]) {

        var matchesDictionary = [MatchUniqueID:MatchObject]()
        var matchesByTeamDictionary = [TeamID:Set<MatchUniqueID>]()
        var matchesByDateDictionary = [DateString: Set<MatchUniqueID>]()
        var matchesByLeagueDictionary = [LeagueID: Set<MatchUniqueID>]()

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
                
                matchesByDateDictionary.add(matchUniqueId, toSetWithKey: matchDate.asKey)
                
                if favoriteTeams.keys.contains(homeTeamId) || favoriteTeams.keys.contains(awayTeamId) {
                    print("Adding \(matchUniqueId)")
                    matchesByLeagueDictionary.add(matchUniqueId, toSetWithKey: DefaultIdentifier.favoriteTeam.rawValue)
                }
                
                // Add to dictionary of all matches
                matchesDictionary[matchUniqueId] = matchData
                
                // Add to set of matches
                matchesByLeagueDictionary.add(matchUniqueId, toSetWithKey: leagueId)
                matchesByTeamDictionary.add(matchUniqueId, toSetWithKey: homeTeamId)
                matchesByTeamDictionary.add(matchUniqueId, toSetWithKey: awayTeamId)
            } else {
                continue
            }
        }
        
        //note(fileName: "Get Matches", "Data Converted")
        return (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary)
    }
    
    func convertDate(data: Data?) async throws -> ([MatchUniqueID:MatchObject], [DateString: Set<MatchUniqueID>]) {
        
        var matchesDictionary = [MatchUniqueID:MatchObject]()
        var matchesByDateDictionary = [DateString: Set<MatchUniqueID>]()

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
                matchesByDateDictionary.add(matchUniqueId, toSetWithKey: matchDate.asKey)
                
                // Add to dictionary of all matches
                matchesDictionary[matchUniqueId] = matchData
            } else {
                continue
            }
        }
        
        //print("Get Matches - Convert Date - Data Converted - \(results.response.count) - \(Date.now.timeStamp)")
        return (matchesDictionary, matchesByDateDictionary)
    }
}
