//
//  Leagues Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class GetLeagues {
    
    static var helper = GetLeagues()

    func getLeaguesFrom(team: TeamObject) async throws -> (TeamObject, [LeagueID:LeagueObject])  {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues?team=\(team.id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (team, leagueDictionary) = try convertLeaguesFor(team: team, data: data)
        return (team, leagueDictionary)
    }
    
    func getAllLeagues() async throws -> [LeagueID:LeagueObject] {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues"
        
       let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let leagueDictionary: [LeagueID:LeagueObject] = try convertAllLeagues(data: data)
        return leagueDictionary
    }
    
    func convertLeaguesFor(team teamObject: TeamObject, data: Data?) throws -> (TeamObject, [LeagueID:LeagueObject]) {

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let team = teamObject
        var leagueDictionary = [LeagueID:LeagueObject]()
        
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
                    break
                } else if season.year > currentSeason {
                    currentSeason = season.year
                    seasonStart = season.start
                    seasonEnd = season.end
                }
            }
            
            guard let league = response.league else { print ("Get Leagues - \(response.league?.name ?? "UNKNOWN LEAGUE") not found")
                continue
            }
            guard currentSeason > 0 else { print ("Get Leagues - \(response.league?.name ?? "UNKNOWN LEAGUE") could not locate season")
                continue }
            
            var flagFileName: String?
            
            if let url = response.country?.flag {
                flagFileName = String(url.split(separator: "/")[3])
                print(flagFileName)
            }
            
            let leagueSearchData = LeagueObject(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: flagFileName, currentSeason: currentSeason, seasonStart: seasonStart, seasonEnd: seasonEnd)
            leagueDictionary[leagueSearchData.id] = leagueSearchData
            team.leagueSet.insert(league.id)
        }
        return (team, leagueDictionary)
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
            
            var flagFileName: String?
            
            if let url = response.country?.flag {
                flagFileName = String(url.split(separator: "/")[3])
            }
            
            let leagueSearchData = LeagueObject(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: flagFileName, currentSeason: currentSeason, seasonStart: seasonStart, seasonEnd: seasonEnd)
            leagueDictionary[leagueSearchData.id] = leagueSearchData
        }
        
        return leagueDictionary
    }
}
