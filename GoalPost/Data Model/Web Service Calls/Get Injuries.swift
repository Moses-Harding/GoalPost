//
//  Get Injuries.swift
//  GoalPost
//
//  Created by Moses Harding on 5/29/22.
//

import Foundation


class GetInjuries {
    static var helper = GetInjuries()
    
    func getInjuriesFor(team id: Int, season: Int) {
        
        //print("Get injuries for \(id), season \(season)")
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/injuries?season=\(season)&team=\(id)"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }
    }
    

    
    func convert(data: Data?) {

        var results: GetInjuriesStructure?

        guard let data = data else {
            return
        }
        do {
            results = try JSONDecoder().decode(GetInjuriesStructure.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }

        for response in responses {

            let injurySearchData = InjuryObject(response)
            
            Cached.injuryDictionary[injurySearchData.id] = injurySearchData
            
            guard let teamId = injurySearchData.team?.id else { return }
            
            var set = Cached.injuriesByTeam[teamId] ?? Set<InjuryID>()
            set.insert(injurySearchData.id)
            Cached.injuriesByTeam[teamId] = set
        }
    }
    
    // Async version
    func getInjuriesFor(team: TeamObject) async throws -> ([InjuryID:InjuryObject], [TeamID:Set<InjuryID>]) {
        
        guard let season = team.mostRecentSeason else { fatalError() }
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/injuries?season=\(season)&team=\(team.id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (injuryDictionary, injuriesByTeam) = try convert(data: data)
        return (injuryDictionary, injuriesByTeam)
    }
    
    func convert(data: Data?) throws -> ([InjuryID:InjuryObject], [TeamID:Set<InjuryID>]) {
        
        var injuryDictionary = [InjuryID:InjuryObject]()
        var injuriesByTeam = [TeamID:Set<InjuryID>]()

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: GetInjuriesStructure = try JSONDecoder().decode(GetInjuriesStructure.self, from: data)
        
        for response in results.response {

            let injurySearchData = InjuryObject(response)
            
            injuryDictionary[injurySearchData.id] = injurySearchData
            
            guard let teamId = injurySearchData.team?.id else { continue }
            
            var set = injuriesByTeam[teamId] ?? Set<InjuryID>()
            set.insert(injurySearchData.id)
            injuriesByTeam[teamId] = set
        }
        
        return (injuryDictionary, injuriesByTeam)
    }
}
