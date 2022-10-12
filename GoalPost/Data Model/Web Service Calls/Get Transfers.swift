//
//  Get Transfers.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation

class GetTransfers {
    
    static var helper = GetTransfers()
    
    func getTransfersFor(team: TeamObject) async throws -> (TransferDictionary, TransfersByTeamDictionary) {
        
        let requestURL = "https://api-football-v1.p.rapidapi.com/v3/transfers?team=\(team.id)"
        let data = try await WebServiceCall().retrieveResults(requestURL: requestURL)
        let (transferDictionary, transfersByTeam) = try convert(data: data)
        return (transferDictionary, transfersByTeam)
    }
    
    func convert(data: Data?) throws -> (TransferDictionary, TransfersByTeamDictionary) {

        var transferDictionary: TransferDictionary = [:]
        var transfersByTeamDictionary: TransfersByTeamDictionary = [:]
        
        guard let data = data else { throw WebServiceCallErrors.dataNotPassedToConversionFunction }
        
        let results: GetTransfersStructure = try JSONDecoder().decode(GetTransfersStructure.self, from: data)

        for response in results.response {
            
            for transfer in response.transfers {

                guard let transferData = TransferObject(getTransfersInformationTransfer: transfer, player: response.player) else {
                    // print("Could not create transfer for \(transfer) with player \(response.player)")
                    continue }
                
                transferDictionary[transferData.id] = transferData

                transfersByTeamDictionary.add(transferData.id, toSetWithKey: transferData.teamToId)
                transfersByTeamDictionary.add(transferData.id, toSetWithKey: transferData.teamFromId)
            }

        }
        
        return (transferDictionary, transfersByTeamDictionary)
    }
}
