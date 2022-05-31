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
        
        print("Get injuries for \(id), season \(season)")
        
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
}
