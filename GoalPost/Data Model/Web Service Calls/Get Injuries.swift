//
//  Get Injuries.swift
//  GoalPost
//
//  Created by Moses Harding on 5/29/22.
//

import Foundation


class GetInjuries {
    static var helper = GetInjuries()

    func getInjuriesFor(team: TeamObject) async throws -> ([InjuryID:InjuryObject], [TeamID:Set<InjuryID>]) {
        
        guard let season = await team.mostRecentSeason() else { fatalError() }
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/injuries?team=\(team.id)&season=\(season)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (injuryDictionary, injuriesByTeam) = try await convert(data: data)
        return (injuryDictionary, injuriesByTeam)
    }
    
    func convert(data: Data?) async throws -> ([InjuryID:InjuryObject], [TeamID:Set<InjuryID>]) {
        
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
