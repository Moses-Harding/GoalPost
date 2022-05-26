//
//  Leagues Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class LeagueSearchDataContainer {
    
    static var helper = LeagueSearchDataContainer()
    
    /*
    func search() {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues"

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
                print("League Data - Retrieve League Data - Error calling /Leagues \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                self.convert(data: data)
            }
        })
        
        dataTask.resume()
    }
     */
    
    func search() {

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/leagues"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }

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
                print("League Data - Retrieve League Data - Error calling /Leagues \(String(describing: error))")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if Testing.manager.verboseWebServiceCalls { print(httpResponse as Any) }
                self.convert(data: data)
            }
        })
        
        dataTask.resume()
    }
    
    
    func convert(data: Data?) {

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
            
            let leagueSearchData = LeagueSearchData(id: league.id, name: league.name, logo: league.logo, type: league.type, country: response.country?.name ?? "N/A", countryLogo: response.country?.flag, currentSeason: currentSeason, seasonStart: seasonStart, seasonEnd: seasonEnd)
            Cached.leagueDictionary[leagueSearchData.id] = leagueSearchData
        }
    }
}
