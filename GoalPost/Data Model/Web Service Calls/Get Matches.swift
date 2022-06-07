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
    
    //var delegate: MatchesViewDelegate?
    
    var dailyMatchData = [String: Dictionary<Int,LeagueObject>]()
    
    init() {

    }
    
    // MARK: Retrieve Data
    /*
    func getMatchesFor(league id: Int, on date: Date) {
        
        // If the league exists in the dictionary, get the current season, otherwise just use the current year
        let season = Cached.leagueDictionary[id]?.currentSeason ?? Calendar.current.component(.year, from: date)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(id))&season=\(season)"

        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }
    }
    
    func getMatchesFor(team id: Int, season: Int) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(id))&season=\(season)"

        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }
    }
    
    func getAllMatchesForCurrentDate() {

        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: today)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(date)"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }
    }
    
    func convert(data: Data?) {
        
        var results: GetMatchesStructure?

        guard let data = data else {
            return
        }
        do {
            results = try JSONDecoder().decode(GetMatchesStructure.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }
        
        for result in responses {
            
            // Get league Details
            let leagueId = result.league.id
            let matchID = result.fixture.id
            let homeTeamId = result.teams.home.id
            let awayTeamId = result.teams.away.id
            
            let matchDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))

            let leagueCountry = result.league.country
            let leagueName = result.league.name

            
            let matchData = MatchObject(getMatchesStructure: result, favoriteTeam: false)

            
            if Cached.favoriteLeagueIds.contains(leagueId) {

                // If matchesByDay already has that day, pull that day up, if not create a new one
                var foundDay = dailyMatchData[matchDate.asKey] ?? [Int:LeagueObject]()
                
                // print("foundDay  - \(foundDay) - \(matchDate)")
                
                // If foundDay already has that league, pull that league up, if not, create a new one
                var foundLeague = foundDay[leagueId] ?? LeagueObject(id: leagueId, name: leagueName, country: leagueCountry, matches: [:])
                
                // print("foundLeague - Matches - count  - \(foundLeague.matches.count)")
                
                // Add matchdata to league's fixutres
                var matches = foundLeague.matches
                matches[matchID] = matchData
                foundLeague.matches = matches
                
                // print("foundLeague - Matches - count  - \(foundLeague.matches.count)")
                
                foundDay[leagueId] = foundLeague
                dailyMatchData[matchDate.asKey] = foundDay
                
                // print("foundDayForLeagueID  - \(foundDay[leagueId])")
                
                Cached.matchesByDay = dailyMatchData
            }
            
            if Cached.favoriteTeamIds.contains(homeTeamId) || Cached.favoriteTeamIds.contains(awayTeamId) {

                let favoriteTeamMatchData = MatchObject(getMatchesStructure: result, favoriteTeam: true)
                
                let favoriteTeamsMatches = Cached.favoriteTeamMatchesByDay[matchDate.asKey] ?? LeagueObject(id: FavoriteTeamLeague.identifer.rawValue, name: "My Teams", country: "NA", matches: [:])

                var matches = favoriteTeamsMatches.matches
                matches[matchID] = favoriteTeamMatchData
                favoriteTeamsMatches.matches = matches
                
                Cached.favoriteTeamMatchesByDay[matchDate.asKey] = favoriteTeamsMatches
            }
            
            // Add to dictionary of all matches
            Cached.matchesDictionary[matchID] = matchData
            
            // Add to set of matches
            var homeSet = Cached.matchesByTeam[homeTeamId] ?? Set<Int>()
            var awaySet = Cached.matchesByTeam[awayTeamId] ?? Set<Int>()
            
            homeSet.insert(matchID)
            awaySet.insert(matchID)
            
            Cached.matchesByTeam[homeTeamId] = homeSet
            Cached.matchesByTeam[awayTeamId] = awaySet
        }
        
        guard let delegate = delegate else {
            fatalError("Delegate not passed to Live Match Data")
        }
        
        DispatchQueue.main.async {
            delegate.refresh()
        }
    }
    */
     
    // Async version
    
    func getMatchesFor(league: LeagueObject) async throws -> ([MatchID:MatchObject], [TeamID:Set<MatchID>], [DateString: Set<MatchID>], [LeagueID: Set<MatchID>], [DateString: Set<MatchID>], [MatchID:MatchObject]) {
        
        guard let season = league.currentSeason else {
            print("WARNING - No season available for league \(league.name)")
            return ([MatchID:MatchObject](), [TeamID:Set<MatchID>](), [DateString: Set<MatchID>](), [LeagueID: Set<MatchID>](), [DateString: Set<MatchID>](), [MatchID:MatchObject]())
        }

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(league.id))&season=\(season)"

        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func getMatchesFor(team: TeamObject) async throws -> ([MatchID:MatchObject], [TeamID:Set<MatchID>], [DateString: Set<MatchID>], [LeagueID: Set<MatchID>], [DateString: Set<MatchID>], [MatchID:MatchObject]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?team=\(String(team.id))&season=\(String(team.mostRecentSeason))"

        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func getMatchesFor(date: Date) async throws -> ([MatchID:MatchObject], [TeamID:Set<MatchID>], [DateString: Set<MatchID>], [LeagueID: Set<MatchID>], [DateString: Set<MatchID>], [MatchID:MatchObject]) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchDate = formatter.string(from: date)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(searchDate)"
        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try convert(data: data)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
    
    func convert(data: Data?) throws -> ([MatchID:MatchObject], [TeamID:Set<MatchID>], [DateString: Set<MatchID>], [LeagueID: Set<MatchID>], [DateString: Set<MatchID>], [MatchID:MatchObject]) {
        
        var matchesDictionary = [MatchID:MatchObject]()
        var matchesByTeam = [TeamID:Set<MatchID>]()
        var matchesByDateSet = [DateString: Set<MatchID>]()
        var matchesByLeagueSet = [LeagueID: Set<MatchID>]()
        var favoriteMatchesByDateSet = [DateString: Set<MatchID>]()
        var favoriteMatchesDictionary = [MatchID:MatchObject]()

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        let results: GetMatchesStructure = try JSONDecoder().decode(GetMatchesStructure.self, from: data)
        
        for result in results.response {
            
            // Get league Details
            let leagueId = result.league.id
            let matchId = result.fixture.id
            let homeTeamId = result.teams.home.id
            let awayTeamId = result.teams.away.id
            
            let matchDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))

            let matchData = MatchObject(getMatchesStructure: result, favoriteTeam: false)

            // Add if it's in a favorite league
            if Cached.favoriteLeagueIds.contains(leagueId) {
                
                matchesByDateSet.add(matchId, toSetWithKey: matchDate.asKey)
            }
            
            // Add if it's a favorite team
            if Cached.favoriteTeamIds.contains(homeTeamId) || Cached.favoriteTeamIds.contains(awayTeamId) {
                
                let favoriteMatchId = FavoriteTeamLeague.identifer.rawValue + matchId
                let favoriteMatchData = MatchObject(getMatchesStructure: result, favoriteTeam: true)
                
                favoriteMatchesByDateSet.add(favoriteMatchId, toSetWithKey: matchDate.asKey)
                favoriteMatchesDictionary[favoriteMatchId] = favoriteMatchData
            }
            
            // Add to dictionary of all matches
            matchesDictionary[matchId] = matchData
            
            // Add to set of matches
            
            matchesByLeagueSet.add(matchId, toSetWithKey: leagueId)
            matchesByTeam.add(matchId, toSetWithKey: homeTeamId)
            matchesByTeam.add(matchId, toSetWithKey: awayTeamId)
        }
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary)
    }
}
