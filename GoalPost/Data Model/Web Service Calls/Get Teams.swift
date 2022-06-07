//
//  Teams Data Container.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation

class GetTeams {
    static var helper = GetTeams()
    
    /*
    var delegate: TeamSearchDelegate?
    func search(for team: String) {
        
        if let delegate = delegate {
            delegate.addSpinner()
        }
        
        let encodedTeam = team.replacingOccurrences(of: " ", with: "+")

        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/teams?search=\(encodedTeam)"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }
    }
    
    
    func convert(data: Data?) {

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
        
        var searchResults = [TeamObject]()
        
        for response in responses {

            let teamSearchData = TeamObject(teamSearchInformation: response)
            Cached.teamDictionary[teamSearchData.id] = teamSearchData
            searchResults.append(teamSearchData)
        }
        
        DispatchQueue.main.async {
            delegate.removeSpinner()
            delegate.returnSearchResults(teamResult: searchResults)
        }
    }
     */
    
    func search(for teamName: String, countryName: String?) async throws -> [TeamID:TeamObject] {
        
        let encodedTeam = teamName.replacingOccurrences(of: " ", with: "+")
        var requestURL = "https://api-football-v1.p.rapidapi.com/v3/teams?search=\(encodedTeam)"
        
        if let encodedCountry = countryName?.replacingOccurrences(of: " ", with: "+") {
            requestURL += "+country=\(encodedCountry)"
        }

        
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let teamDictionary: [TeamID:TeamObject] = try convert(data: data)
        return teamDictionary
    }
    
    func convert(data: Data?) throws -> [TeamID:TeamObject] {

        var teamDictionary = [TeamID:TeamObject]()
        
        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: TeamSearchStructure = try JSONDecoder().decode(TeamSearchStructure.self, from: data)
        
        print(results)
        
        for response in results.response {

            let teamSearchData = TeamObject(teamSearchInformation: response)
            teamDictionary[teamSearchData.id] = teamSearchData
        }
        
        return teamDictionary
    }
}
