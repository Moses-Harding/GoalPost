//
//  Live Fixture Data.swift
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
    
    var dailyFixtureData = [String: Dictionary<Int,MatchLeagueData>]()
    
    init() {

    }
    
    // MARK: Retrieve Data
    
    func retrieveFixturesFromFavoriteLeagues(update: Bool) {
        
        print("Getting all matches for favorite leagues")
        
        Cached.leagues.forEach { retrieveFixtureData(for: $0, date: Date.now, update: update) }
    }
    
    func retrieveFixtureData(for leagueID: Int, date: Date, update: Bool) {
        
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
                self.convert(data: data, update: update)
            }
        })

        dataTask.resume()
    }
    
    func retrieveAllFixturesForCurrentDate(update: Bool) {

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
                print("Live Fixture Data - retrieveAllFixturesForCurrentDate - Error calling /fixtures \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                self.convert(data: data, update: update)
            }
        })

        dataTask.resume()
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
            let fixtureDate = Date(timeIntervalSince1970: TimeInterval(result.fixture.timestamp))
            let timeElapsed = result.fixture.status.elapsed
            let status = result.fixture.status.short
             
            // Get league Details
            let leagueId = result.league.id
            let leagueCountry = result.league.country
            let leagueName = result.league.name
            
            // Get match details
            let matchID = result.fixture.id
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
            
            let fixtureData = MatchData(homeTeam: homeTeam, awayTeam: awayTeam, status: status, timeElapsed: timeElapsed, timeStamp: fixtureDate, favoriteTeam: false, id: matchID)

            
            if Cached.leagues.contains(leagueId) {

                // If fixturesByDay already has that day, pull that day up, if not create a new one
                var foundDay = dailyFixtureData[fixtureDate.asKey] ?? [Int:MatchLeagueData]()
                
                // print("foundDay  - \(foundDay) - \(fixtureDate)")
                
                // If foundDay already has that league, pull that league up, if not, create a new one
                var foundLeague = foundDay[leagueId] ?? MatchLeagueData(name: leagueName, country: leagueCountry, id: leagueId, fixtures: [:])
                
                // print("foundLeague - Fixtures - count  - \(foundLeague.fixtures.count)")
                
                // Add fixturedata to league's fixutres
                var fixtures = foundLeague.fixtures
                fixtures[matchID] = fixtureData
                foundLeague.fixtures = fixtures
                
                // print("foundLeague - Fixtures - count  - \(foundLeague.fixtures.count)")
                
                foundDay[leagueId] = foundLeague
                dailyFixtureData[fixtureDate.asKey] = foundDay
                
                // print("foundDayForLeagueID  - \(foundDay[leagueId])")
                
                Cached.matches = dailyFixtureData
            }
            
            if Cached.teams.contains(homeTeamId) || Cached.teams.contains(awayTeamID) {
                
                let favoriteTeamFixtureData = MatchData(homeTeam: homeTeam, awayTeam: awayTeam, status: status, timeElapsed: timeElapsed, timeStamp: fixtureDate, favoriteTeam: true, id: matchID)
                
                if Cached.favoriteTeamMatches == nil { Cached.favoriteTeamMatches = [:] }
                
                var favoriteTeamsFixtures = Cached.favoriteTeamMatches[fixtureDate.asKey] ?? MatchLeagueData(name: "My Teams", country: "NA", id: FavoriteTeamLeague.identifer.rawValue, fixtures: [:])


                var fixtures = favoriteTeamsFixtures.fixtures
                fixtures[matchID] = favoriteTeamFixtureData
                favoriteTeamsFixtures.fixtures = fixtures
                
                Cached.favoriteTeamMatches[fixtureDate.asKey] = favoriteTeamsFixtures
            }
        }
        
        guard let delegate = delegate else {
            fatalError("Delegate not passed to Live Fixture Data")
        }
        
        DispatchQueue.main.async {
            delegate.refresh(update: update)
        }
    }
}


// MARK: Structures used in MatchesDataContainer

struct MatchData: Codable, Hashable {
    var homeTeam: MatchTeamData
    var awayTeam: MatchTeamData
    var status: FixtureStatusCode
    var timeElapsed: Int?
    var timeStamp: Date
    var favoriteTeam: Bool
    var id: Int
}

struct MatchLeagueData: Codable, Hashable {
    var name: String
    var country: String
    var id: Int
    var fixtures: [Int:MatchData]
}

struct MatchTeamData: Codable, Hashable {
    var name: String
    var id: Int
    var logoURL: String
    var score: Int?
}

// MARK: Ad Data Contianer

struct AdData: Codable, Hashable {
    
    static var countOfAds = 0
    var name: String
    var adViewName: AdViewName
    var viewWidth: Float
    
    init(adViewName: AdViewName, viewWidth: Float) {
        self.adViewName = adViewName
        self.name = "Ad " + String(AdData.countOfAds) + " - " + adViewName.rawValue
        self.viewWidth = viewWidth
        AdData.countOfAds += 1
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
        case .fixture(let matchData):
            self.name = String(matchData.homeTeam.id) + String(matchData.awayTeam.id) + DateFormatter().string(from: matchData.timeStamp)
        case .ad(let adData):
            self.name = adData.name
        }
    }
}
