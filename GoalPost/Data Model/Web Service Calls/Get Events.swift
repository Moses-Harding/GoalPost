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
        let events = try await convert(data: data, for: id)
        
        return events
    }
    
    func convert(data: Data?, for matchId: MatchID) async throws -> MatchesDictionary {
        
        var matchesDictionary: MatchesDictionary = [:]

        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }

        let decoder = JSONDecoder()

        do {
            let results: GetEventsStructure = try decoder.decode(GetEventsStructure.self, from: data)

        } catch  {
            print(error)
        }
        
        let results: GetEventsStructure = try decoder.decode(GetEventsStructure.self, from: data)
        
        guard let match = QuickCache.helper.matchesDictionary[matchId] else { fatalError("GetEvents - ConvertData - No match located for id specified") }
        
        for result in results.response {
            
            let event = EventObject(result)
            
            match.events.append(event)
        }
        matchesDictionary[matchId] = match

        return matchesDictionary
    }
}
