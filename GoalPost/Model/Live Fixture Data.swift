//
//  Live Fixture Data.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation

//https://rapidapi.com/api-sports/api/api-football/

class LiveFixtureDataContainer {
    
    var delegate: Refreshable?
    
    var dailyFixtureData = Cached.dailyFixtures
    
    var favoriteCountries = ["England", "Spain", "Italy", "France", "Germany", "Portugal"]
    var favoriteLeagues = ["La Liga", "Ligue 1", "Serie A", "Bundesliga 1", "Championship", "Premier League"]
    
    init() {
        configureFavoriteLeagues()
        if Testing.manager.webServiceCallsEnabled { retrieveFixturesFromFavoriteLeagues() }
    }
    
    func configureFavoriteLeagues() {
        if Saved.leagues.isEmpty {
            Saved.leagues = [39, 61, 78, 135, 140]

        }
    }
    
    func getNextDay(from date: Date) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = 1
        
        let newDate = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
        return newDate
    }
    
    func getPreviousDay(from date: Date) -> Date {
        var dateComponent = DateComponents()
        dateComponent.day = -1
        
        let newDate = Calendar.current.date(byAdding: dateComponent, to: date) ?? date
        return newDate
    }
    
    // MARK: Retrieve Data
    
    func retrieveFixturesFromFavoriteLeagues() {
        Saved.leagues.forEach { retrieveFixtureData(for: $0, date: Date.now) }
    }
    
    func retrieveFixtureData(for leagueID: Int, date: Date) {
        
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
                print("Live Fixture Data - Retrieve Fixture Data - Error calling /fixtures \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                self.convert(data: data)
            }
        })

        dataTask.resume()
    }
    
    func convert(data: Data?) {

        var results: FixtureResults?
        
        guard let data = data else {
            return
        }
        do {
            results = try JSONDecoder().decode(FixtureResults.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }
        
        for result in responses {
            
            // Get Date
            let fixtureDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))
            let timeElapsed = result.fixture.status.elapsed
             
            // Get league Details
            let leagueId = result.league.id
            let leagueCountry = result.league.country
            let leagueName = result.league.name

            
            // Get team details
            let homeTeamName = result.teams.home.name
            let homeTeamId = result.teams.home.id
            let homeTeamLogo = result.teams.home.logo
            let homeTeamScore = result.goals.home
            let awayTeamName = result.teams.away.name
            let awayTeamID = result.teams.away.id
            let awayTeamLogo = result.teams.away.logo
            let awayTeamScore = result.goals.away
            
            // Create data structures
            let homeTeam = FixtureTeamData(name: homeTeamName, id: homeTeamId, logoURL: homeTeamLogo, score:
                                            homeTeamScore)
            let awayTeam = FixtureTeamData(name: awayTeamName, id: awayTeamID, logoURL: awayTeamLogo, score:
                                            awayTeamScore)
            
            let fixtureData = FixtureData(homeTeam: homeTeam, awayTeam: awayTeam, timeElapsed: timeElapsed, timeStamp: fixtureDate)
            
            // If fixturesByDay already has that day, pull that day up, if not create a new one
            var foundDay = dailyFixtureData[fixtureDate.asKey] ?? [Int:LeagueData]()
            
            //print("foundDay  - \(foundDay) - \(fixtureDate)")
            
            // If foundDay already has that league, pull that league up, if not, create a new one
            var foundLeague = foundDay[leagueId] ?? LeagueData(name: leagueName, country: leagueCountry, id: leagueId, fixtures: [])
            
            // print("foundLeague - Fixtures - count  - \(foundLeague.fixtures.count)")
            
            // Add fixturedata to league's fixutres
            let fixtures = foundLeague.fixtures + [fixtureData]
            foundLeague.fixtures = fixtures
            
            // print("foundLeague - Fixtures - count  - \(foundLeague.fixtures.count)")
            
            foundDay[leagueId] = foundLeague
            dailyFixtureData[fixtureDate.asKey] = foundDay
            
            //print("foundDayForLeagueID  - \(foundDay[leagueId])")
            
            Cached.dailyFixtures = dailyFixtureData
        }
        
        guard let delegate = delegate else {
            fatalError("Delegate not passed to Live Fixture Data")
        }
        
        DispatchQueue.main.async {
            delegate.refresh()
        }
    }
}
