//
//  Transfer.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation

class TransferObject: Codable {
    
    func player() async -> PlayerObject? {
        return await Cached.data.playerDictionary(playerId)
    }
    
    var teamTo: TeamObject? {
        return QuickCache.helper.teamDictionary[teamToId]
    }
    
    var teamFrom: TeamObject? {
        return QuickCache.helper.teamDictionary[teamFromId]
    }
    
    
    var playerId: PlayerID
    var transferDate: Date
    var transferType: String
    var teamToId: TeamID
    var teamFromId: TeamID
    
    var id: TransferID
    
    init?(getTransfersInformationTransfer transfer: GetTransfersInformation_Transfer, player: GetTransfersInformation_Player) {
        
        guard let teamsIn = transfer.teams.teamsIn, let teamsOut = transfer.teams.teamsOut, let teamToId = teamsIn.id, let teamFromId = teamsOut.id, let teamToName = teamsIn.name, let teamFromName = teamsOut.name, let playerName = player.name else { return nil }
        
        let dateString = transfer.date.split(separator: "-")

        guard dateString.count == 3 else { return nil }
        guard let year = Int(dateString[0]), year <= Calendar.current.component(.year, from: Date.now) else { return nil }
        guard let month = Int(dateString[1]) else { return nil }
        guard let day = Int(dateString[2]) else { return nil }
        let components = DateComponents(year: year, month: month, day: day)
        
        guard let date = Calendar.current.date(from: components) else { return nil }
        
        self.playerId = player.id
        self.transferDate = date
        self.transferType = transfer.type ?? "N/A"
        self.teamToId = teamToId
        self.teamFromId = teamFromId
        
        self.id = "\(year)\(month)\(day) - \(playerId) - \(teamToId) - \(teamFromId)"
         
        Task.init{
            await Cached.data.teamDictionaryAddIfNoneExists(TeamObject(id: teamToId, name: teamToName, logo: teamsIn.logo), key: teamToId)
            await Cached.data.teamDictionaryAddIfNoneExists(TeamObject(id: teamFromId, name: teamFromName, logo: teamsOut.logo), key: teamFromId)
            await Cached.data.playerDictionaryAddIfNoneExists(PlayerObject(id: player.id, name: playerName, photo: nil), key: player.id)
        }
    }
}
