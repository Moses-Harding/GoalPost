//
//  Teams Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class TeamSearchDataContainer {
    
    var delegate: TeamSearchDelegate?
    
    func search(for team: String) {
        
        if let delegate = delegate {
            delegate.addSpinner()
        }
        
        let encodedTeam = team.replacingOccurrences(of: " ", with: "+")

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/teams?search=\(encodedTeam)"

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
                self.convertSearch(data: data)
            }
        })
        
        dataTask.resume()
    }
    
    
    func convertSearch(data: Data?) {
        
        if Cached.teamDictionary == nil {
            Cached.teamDictionary = [:]
        }

        var results: TeamSearchStructure?

        guard let data = data else {
            return
        }
        do {
            results = try JSONDecoder().decode(TeamSearchStructure.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }
        
        guard let delegate = delegate else {
            fatalError()
        }
        
        var searchResults = [TeamSearchData]()
        
        for response in responses {
            let teamSearchVenue = TeamSearchVenue(id: response.venue?.id, name: response.venue?.name, address: response.venue?.address, city: response.venue?.city, capacity: response.venue?.capacity, surface: response.venue?.surface, image: response.venue?.image)
            let teamSearchData = TeamSearchData(id: response.team.id, name: response.team.name, code: response.team.code, country: response.team.country, founded: response.team.founded, national: response.team.national, logo: response.team.logo, venue: teamSearchVenue)
            Cached.teamDictionary[teamSearchData.id] = teamSearchData
            searchResults.append(teamSearchData)
        }
        
        DispatchQueue.main.async {
            delegate.removeSpinner()
            delegate.returnSearchResults(teamResult: searchResults)
        }
    }
}


// MARK: Structures used in TeamSearchDataContainer

struct TeamSearchData: Codable, Hashable {
    let id: Int
    let name: String
    let code: String?
    let country: String?
    let founded: Int?
    let national: Bool
    let logo: String?
    let venue: TeamSearchVenue
}

struct TeamSearchVenue: Codable, Hashable {
    let id: Int?
    let name: String?
    let address: String?
    let city: String?
    let capacity: Int?
    let surface: String?
    let image: String?
}
