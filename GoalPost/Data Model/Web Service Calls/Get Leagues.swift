//
//  Leagues Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class GetLeagues {
    
    static var helper = GetLeagues()
    
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
}
