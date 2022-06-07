//
//  Get Transfers.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation


class GetTransfers {
    
    static var helper = GetTransfers()
    
    /*
    func getTransfersFor(team id: Int) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/transfers?team=\(id)"
        
        WebServiceCall().retrieveResults(requestURL: requestURL) { self.convert(data: $0) }
    }
    
    func convert(data: Data?) {

        var results: GetTransfersStructure?

        guard let data = data else {
            return
        }
        
        do {
            results = try JSONDecoder().decode(GetTransfersStructure.self, from: data)
        } catch {
            print(error)
        }
        
        guard let responses = results?.response else { return }

        for response in responses {
            
            for transfer in response.transfers {
                guard let transferData = TransferObject(getTransfersInformationTransfer: transfer, player: response.player) else { continue }
                
                Cached.transferDictionary[transferData.id] = transferData
                
                let homeTeamID = transferData.teamToId
                let awayTeamID = transferData.teamFromId
                
                var homeSet = Cached.transfersByTeam[homeTeamID] ?? Set<TransferID>()
                homeSet.insert(transferData.id)
                Cached.transfersByTeam[homeTeamID] = homeSet
                var awaySet = Cached.transfersByTeam[awayTeamID] ?? Set<TransferID>()
                awaySet.insert(transferData.id)
                Cached.transfersByTeam[awayTeamID] = awaySet
            }

        }
    }
     */
    
    // Async versions
    
    func getTransfersFor(team: TeamObject) async throws -> ([TransferID:TransferObject], [TeamID:Set<TransferID>]) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/transfers?team=\(team.id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (transferDictionary, transfersByTeam) = try convert(data: data)
        return (transferDictionary, transfersByTeam)
    }
    
    func convert(data: Data?) throws -> ([TransferID:TransferObject], [TeamID:Set<TransferID>]) {

        var transferDictionary = [TransferID:TransferObject]()
        var transfersByTeam = [TeamID:Set<TransferID>]()
        
        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: GetTransfersStructure = try JSONDecoder().decode(GetTransfersStructure.self, from: data)

        for response in results.response {
            
            for transfer in response.transfers {

                guard let transferData = TransferObject(getTransfersInformationTransfer: transfer, player: response.player) else { continue }
                
                transferDictionary[transferData.id] = transferData

                transfersByTeam.add(transferData.id, toSetWithKey: transferData.teamToId)
                transfersByTeam.add(transferData.id, toSetWithKey: transferData.teamFromId)
            }

        }
        
        return (transferDictionary, transfersByTeam)
    }
}
