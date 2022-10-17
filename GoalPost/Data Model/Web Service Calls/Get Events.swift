//
//  Get Events.swift
//  GoalPost
//
//  Created by Moses Harding on 10/14/22.
//

//https://rapidapi.com/api-sports/api/api-football/

import Foundation


class GetEvents {
    
    static var helper = GetEvents()
    
    
    func getEventsFor(match id: MatchID) async throws -> MatchesDictionary {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/fixtures/events?fixture=\(id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        print("1")
        let events = try await convert(data: data, for: id)
        print("5")
        
        return events
    }
    
    func convert(data: Data?, for matchId: MatchID) async throws -> MatchesDictionary {
        
        var matchesDictionary: MatchesDictionary = [:]
        
        print("2")

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        print("3")
        

        let decoder = JSONDecoder()

        do {
            let results: GetEventsStructure = try decoder.decode(GetEventsStructure.self, from: data)

        } catch  {
            print(error)
        }
        
        let results: GetEventsStructure = try decoder.decode(GetEventsStructure.self, from: data)
        
        print("4")
        
        guard let match = QuickCache.helper.matchesDictionary[matchId] else { fatalError("GetEvents - ConvertData - No match located for id specified") }
        
        for result in results.response {
            
            let event = EventObject(result)
            
            match.events.append(event)
        }
        matchesDictionary[matchId] = match

        return matchesDictionary
    }
}
