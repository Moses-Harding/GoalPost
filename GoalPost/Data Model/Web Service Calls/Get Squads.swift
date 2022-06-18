//
//  Get Squads.swift
//  GoalPost
//
//  Created by Moses Harding on 6/13/22.
//

import Foundation

class GetSquad {
    
    static var helper = GetSquad()
    
    func getSquadFor(team: TeamObject) async throws -> ([PlayerID:PlayerObject], [TeamID:Set<PlayerID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/players/squads?team=\(team.id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (playerDictionary, playersByTeam) = try convert(data: data)
        return (playerDictionary, playersByTeam)
    }
    
    func convert(data: Data?) throws -> ([PlayerID:PlayerObject], [TeamID:Set<PlayerID>]) {

        var playerDictionary = [PlayerID:PlayerObject]()
        var playersByTeam = [TeamID:Set<PlayerID>]()
        
        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: GetSquadStructure = try JSONDecoder().decode(GetSquadStructure.self, from: data)

        for response in results.response {
            
            let teamId = response.team.id
            
            for player in response.players {
                
                let playerData = PlayerObject(getSquadInformationPlayer: player, team: teamId)
                
                playerDictionary[playerData.id] = playerData

                playersByTeam.add(playerData.id, toSetWithKey: teamId)
            }

        }
        
        return (playerDictionary, playersByTeam)
    }
}
