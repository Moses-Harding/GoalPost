//
//  Live Fixture Data.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation

//https://rapidapi.com/api-sports/api/api-football/

class LiveFixtureDataContainer {
    
    var leagues = [Int:LeagueData]()
    
    var numberOfLeagues: Int {
        return leagues.count
    }
    
    var numberOfFixtures: Int {
        var number = 0
        for league in leagues {
            number += league.value.fixtures.count
        }
        return number
    }
    
    var delegate: Refreshable?
    
    var favoriteCountries = ["England", "Spain", "Italy", "France", "Germany", "Portugal"]
    var favoriteLeagues = ["La Liga", "Ligue 1", "Serie A", "Bundesliga 1", "Championship", "Premier League"]
    
    init() {
        retrieveFixtureData(for: Date.now)
    }
    
    func testData() {
        
        /* DUMMY DATA */
        let laLiga = LeagueData(name: "La Liga", fixtures: [FixtureData(homeTeam: FixtureTeamData(name: "Barcelona", score: 4), awayTeam: FixtureTeamData(name: "Real Madrid", score: 0), timeElapsed: 5), FixtureData(homeTeam: FixtureTeamData(name: "Atletico Madrid", score: 2), awayTeam: FixtureTeamData(name: "Real Betis", score: 1), timeElapsed: 45), FixtureData(homeTeam: FixtureTeamData(name: "Cadiz", score: 0), awayTeam: FixtureTeamData(name: "Atletico Madrid", score: 0), timeElapsed: 90)])
        let premierLeague = LeagueData(name: "Premier League", fixtures: [FixtureData(homeTeam: FixtureTeamData(name: "Liverpool", score: 2), awayTeam: FixtureTeamData(name: "Chelsea", score: 0), timeElapsed: 35), FixtureData(homeTeam: FixtureTeamData(name: "Tottenham Hotspur", score: 1), awayTeam: FixtureTeamData(name: "Manchester City", score: 3), timeElapsed: 10), FixtureData(homeTeam: FixtureTeamData(name: "Crystal Palace", score: 3), awayTeam: FixtureTeamData(name: "Southampton", score: 2), timeElapsed: 7)])
        
        leagues[0] = laLiga
        leagues[1] = premierLeague
    }
    
    func configureFavoriteLeagues() {
        
    }
    
    func getNextDay(from date: Date) -> Date {
        let newDate = Calendar.current.nextDate(after: date, matching: DateComponents.init(calendar: Calendar.current), matchingPolicy: Calendar.MatchingPolicy.nextTime, direction: .forward) ?? date
        print(newDate)
        return newDate
    }
    
    func getPreviousDay(from date: Date) -> Date {
        let newDate = Calendar.current.nextDate(after: date, matching: DateComponents.init(calendar: Calendar.current), matchingPolicy: Calendar.MatchingPolicy.previousTimePreservingSmallerComponents, direction: .backward) ?? date
        print(newDate)
        return newDate
    }
    
    // MARK: Retrieve Data
    
    func retrieveFixtureData(for date: Date) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var formattedDate = formatter.string(from: date)
        
        let headers = [
            "X-RapidAPI-Host": "api-football-v1.p.rapidapi.com",
            "X-RapidAPI-Key": "c1164f49eamsh738fee22e3cadc3p1b9a2djsnca6241604f73"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api-football-v1.p.rapidapi.com/v3/fixtures?date=\(formattedDate)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("Live Fixture Data - Retrieve Fixture Data - Error calling /fixtures \(error)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse) }
                self.convert(data: data)
            }
        })

        dataTask.resume()
    }
    
    func convert(data: Data?) {
        
        var leagueData = [Int:LeagueData]()
        
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
            
            let leagueId = result.league.id
            let leagueCountry = result.league.country
            let leagueName = result.league.name
            
            /*
            if !favoriteCountries.contains(leagueCountry) {
                continue
            }
            
            if !favoriteLeagues.contains(leagueName) {
                continue
            }
             */
            
            let homeTeam = FixtureTeamData(name: result.teams.home.name, score: result.goals.home ?? 0)
            let awayTeam = FixtureTeamData(name: result.teams.away.name, score: result.goals.away ?? 0)
            let fixtureData = FixtureData(homeTeam: homeTeam, awayTeam: awayTeam, timeElapsed: Float(result.fixture.status.elapsed ?? 0))

            if let foundLeague = leagueData[leagueId] {
                var fixtures = foundLeague.fixtures
                fixtures.append(fixtureData)
                leagueData[leagueId]?.fixtures = fixtures
            } else {
                let league = LeagueData(name: leagueName, country: leagueCountry, id: leagueId, fixtures: [fixtureData])
                leagueData[leagueId] = league
            }
        }
        
        leagues = leagueData
        
        guard let delegate = delegate else {
            fatalError("Delegate not passed to Live Fixture Data")
        }
        
        DispatchQueue.main.async {
            delegate.refresh()
        }
    }
}
