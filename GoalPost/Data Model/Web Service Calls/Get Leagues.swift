//
//  Leagues Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class GetLeagues {
    
    static var helper = GetLeagues()
    
    /*
    func getAllLeagues() {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convertAllLeagues(data: $0) }
    }
    
    func getLeaguesFrom(team id: Int) {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues?team=\(id)"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convertLeaguesFor(team: id, data: $0) }
    }
    
    func convertLeaguesFor(team id: Int, data: Data?) {
        
        guard var retrievedTeam = Cached.teamDictionary[id] else {
            print("GetLeagues - convertLeaguesForTeam - Cannot retrieve team from ID")
            return
        }
        
        var results: LeagueSearchStructure?

        guard let data = data else {
            return
        }
        do {
            results = try JSONDecoder().decode(LeagueSearchStructure.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }
        
        for response in responses {
            
            var currentSeason: Int?
            var seasonStart: String = ""
            var seasonEnd: String = ""
            
            for season in response.seasons {
                if season.current {
                    currentSeason = season.year
                    seasonStart = season.start
                    seasonEnd = season.end
                }
            }
            
            guard let league = response.league, let season = currentSeason else { continue }
            
            let leagueSearchData = LeagueObject(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: response.country?.flag, currentSeason: season, seasonStart: seasonStart, seasonEnd: seasonEnd, matches: nil)
            retrievedTeam.leagueDictionary[leagueSearchData.id] = leagueSearchData
        }
        
        // After adding teams, update dictionary
        Cached.teamDictionary[id] = retrievedTeam
    }
    
    func convertAllLeagues(data: Data?) {

        var results: LeagueSearchStructure?

        guard let data = data else {
            return
        }
        do {
            results = try JSONDecoder().decode(LeagueSearchStructure.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }
        
        for response in responses {
            
            var currentSeason: Int = 0
            var seasonStart: String = ""
            var seasonEnd: String = ""
            
            for season in response.seasons {
                if season.current {
                    currentSeason = season.year
                    seasonStart = season.start
                    seasonEnd = season.end
                }
            }
            
            guard let league = response.league else { continue }
            
            let leagueSearchData = LeagueObject(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: response.country?.flag, currentSeason: currentSeason, seasonStart: seasonStart, seasonEnd: seasonEnd, matches: nil)
            Cached.leagueDictionary[leagueSearchData.id] = leagueSearchData
        }
    }
    */
     
    // MARK: Async versions
    
    func getLeaguesFrom(team: TeamObject) async throws -> TeamObject {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues?team=\(team.id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let team = try convertLeaguesFor(team: team, data: data)
        return team
    }
    
    func getAllLeagues() async throws -> [LeagueID:LeagueObject] {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues"
        
       let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let leagueDictionary: [LeagueID:LeagueObject] = try convertAllLeagues(data: data)
        return leagueDictionary
    }
    
    func convertLeaguesFor(team: TeamObject, data: Data?) throws -> TeamObject {

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: LeagueSearchStructure = try JSONDecoder().decode(LeagueSearchStructure.self, from: data)

        for response in results.response {
            
            var currentSeason: Int?
            var seasonStart: String = ""
            var seasonEnd: String = ""
            
            for season in response.seasons {
                if season.current {
                    currentSeason = season.year
                    seasonStart = season.start
                    seasonEnd = season.end
                }
            }
            
            guard let league = response.league, let season = currentSeason else { continue }
            
            let leagueSearchData = LeagueObject(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: response.country?.flag, currentSeason: season, seasonStart: seasonStart, seasonEnd: seasonEnd, matches: nil, matchSet: nil)
            team.leagueDictionary[leagueSearchData.id] = leagueSearchData
        }
        
        return team
    }
    
    func convertAllLeagues(data: Data?) throws -> [LeagueID:LeagueObject] {
        
        var leagueDictionary = [LeagueID:LeagueObject]()

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: LeagueSearchStructure = try JSONDecoder().decode(LeagueSearchStructure.self, from: data)

        for response in results.response {
            
            var currentSeason: Int = 0
            var seasonStart: String = ""
            var seasonEnd: String = ""
            
            for season in response.seasons {
                if season.current {
                    currentSeason = season.year
                    seasonStart = season.start
                    seasonEnd = season.end
                }
            }
            
            guard let league = response.league else { continue }
            
            let leagueSearchData = LeagueObject(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: response.country?.flag, currentSeason: currentSeason, seasonStart: seasonStart, seasonEnd: seasonEnd, matches: nil, matchSet: nil)
            leagueDictionary[leagueSearchData.id] = leagueSearchData
        }
        
        return leagueDictionary
    }
}
