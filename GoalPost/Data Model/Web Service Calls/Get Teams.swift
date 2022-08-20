//
//  Teams Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class GetTeams {
    
    static var helper = GetTeams()
    
    func search(for teamName: String, countryName: String?) async throws -> [TeamID:TeamObject] {
        
        let encodedTeam = teamName.replacingOccurrences(of: " ", with: "+")
        var requestURL = "https://api-football-v1.p.rapidapi.com/v3/teams?search=\(encodedTeam)"
        
        if let encodedCountry = countryName?.replacingOccurrences(of: " ", with: "+") {
            if encodedCountry != "" {
                requestURL += "&country=\(encodedCountry)"
            }
        }

        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let teamDictionary: [TeamID:TeamObject] = try convert(data: data)
        return teamDictionary
    }
    
    func convert(data: Data?) throws -> [TeamID:TeamObject] {

        var teamDictionary = [TeamID:TeamObject]()
        
        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: TeamSearchStructure = try JSONDecoder().decode(TeamSearchStructure.self, from: data)
        
        for response in results.response {

            let teamSearchData = TeamObject(teamSearchInformation: response)
            teamDictionary[teamSearchData.id] = teamSearchData
        }
        
        return teamDictionary
    }
}
