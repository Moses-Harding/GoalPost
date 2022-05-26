//
//  Live Match Data.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation

//https://rapidapi.com/api-sports/api/api-football/

// The container that stores current matches

class MatchesDataContainer {
    
    static var helper = MatchesDataContainer()
    
    var delegate: MatchesViewDelegate?
    
    var dailyMatchData = [String: Dictionary<Int,MatchLeagueData>]()
    
    init() {

    }
    
    // MARK: Retrieve Data
    
    func retrieveMatchesFromFavoriteLeagues(update: Bool) {
        
        print("Getting all matches for favorite leagues")
        
        Cached.leagues.forEach { retrieveMatchData(for: $0, date: Date.now, update: update) }
    }
    
    /*
    func retrieveMatchData(for leagueID: Int, date: Date, update: Bool) {
        
        // The API requires a four digit season. There's no easy way to tell what the current season is, but the season typically changes between June - August, so if it's after July, then the season is the current year.
        
        var season: Int
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        if month > 7 {
            season = year
        } else {
            season = year - 1
        }
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(leagueID))&season=\(season)"

        
        let headers = [
            "X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
            "X-RapidAPI-Key": Secure.rapidAPIKey
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: requestURL)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                                          
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Live Match Data - Retrieve Match Data - Error calling /matchs \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                self.convert(data: data, update: update)
            }
        })

        dataTask.resume()
    }
    
    
    func retrieveAllMatchesForCurrentDate(update: Bool) {

        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: today)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(date)"

        let headers = [
            "X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
            "X-RapidAPI-Key": Secure.rapidAPIKey
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: requestURL)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                                          
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Live Match Data - retrieveAllMatchesForCurrentDate - Error calling /fixtures \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                self.convert(data: data, update: update)
            }
        })

        dataTask.resume()
    }
     
     */
    
    func retrieveMatchData(for leagueID: Int, date: Date, update: Bool) {
        
        // The API requires a four digit season. There's no easy way to tell what the current season is, but the season typically changes between June - August, so if it's after July, then the season is the current year.
        
        var season: Int
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        if month > 7 {
            season = year
        } else {
            season = year - 1
        }
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(String(leagueID))&season=\(season)"

        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0, update: update) }
        
    }
    
    func retrieveAllMatchesForCurrentDate(update: Bool) {

        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: today)
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(date)"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0, update: update) }
    }
    
    func convert(data: Data?, update: Bool) {
        
        print("CONVERT DATA__\n__")

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
            
            // Get Date
            let matchDate = Date(timeIntervalSince1970: TimeInterval(result.match.timestamp))
            let timeElapsed = result.match.status.elapsed
            let status = result.match.status.short
             
            // Get league Details
            let leagueId = result.league.id
            let leagueCountry = result.league.country
            let leagueName = result.league.name
            
            // Get match details
            let matchID = result.match.id
            let homeTeamName = result.teams.home.name
            let homeTeamId = result.teams.home.id
            let homeTeamLogo = result.teams.home.logo
            let homeTeamScore = result.goals.home
            let awayTeamName = result.teams.away.name
            let awayTeamID = result.teams.away.id
            let awayTeamLogo = result.teams.away.logo
            let awayTeamScore = result.goals.away
            
            
            // Create data structures
            let homeTeam = MatchTeamData(name: homeTeamName, id: homeTeamId, logoURL: homeTeamLogo, score:
                                            homeTeamScore)
            let awayTeam = MatchTeamData(name: awayTeamName, id: awayTeamID, logoURL: awayTeamLogo, score:
                                            awayTeamScore)
            
            let matchData = MatchData(homeTeam: homeTeam, awayTeam: awayTeam, status: status, timeElapsed: timeElapsed, timeStamp: matchDate, favoriteTeam: false, id: matchID)

            
            if Cached.leagues.contains(leagueId) {

                // If matchesByDay already has that day, pull that day up, if not create a new one
                var foundDay = dailyMatchData[matchDate.asKey] ?? [Int:MatchLeagueData]()
                
                // print("foundDay  - \(foundDay) - \(matchDate)")
                
                // If foundDay already has that league, pull that league up, if not, create a new one
                var foundLeague = foundDay[leagueId] ?? MatchLeagueData(name: leagueName, country: leagueCountry, id: leagueId, matches: [:])
                
                // print("foundLeague - Matches - count  - \(foundLeague.matches.count)")
                
                // Add matchdata to league's fixutres
                var matches = foundLeague.matches
                matches[matchID] = matchData
                foundLeague.matches = matches
                
                // print("foundLeague - Matches - count  - \(foundLeague.matches.count)")
                
                foundDay[leagueId] = foundLeague
                dailyMatchData[matchDate.asKey] = foundDay
                
                // print("foundDayForLeagueID  - \(foundDay[leagueId])")
                
                Cached.matches = dailyMatchData
            }
            
            if Cached.teams.contains(homeTeamId) || Cached.teams.contains(awayTeamID) {
                
                let favoriteTeamMatchData = MatchData(homeTeam: homeTeam, awayTeam: awayTeam, status: status, timeElapsed: timeElapsed, timeStamp: matchDate, favoriteTeam: true, id: matchID)
                
                if Cached.favoriteTeamMatches == nil { Cached.favoriteTeamMatches = [:] }
                
                var favoriteTeamsMatches = Cached.favoriteTeamMatches[matchDate.asKey] ?? MatchLeagueData(name: "My Teams", country: "NA", id: FavoriteTeamLeague.identifer.rawValue, matches: [:])


                var matches = favoriteTeamsMatches.matches
                matches[matchID] = favoriteTeamMatchData
                favoriteTeamsMatches.matches = matches
                
                Cached.favoriteTeamMatches[matchDate.asKey] = favoriteTeamsMatches
            }
        }
        
        guard let delegate = delegate else {
            fatalError("Delegate not passed to Live Match Data")
        }
        
        DispatchQueue.main.async {
            delegate.refresh(update: update)
        }
    }
}
