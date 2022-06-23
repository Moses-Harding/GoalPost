//
//  Types.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation

typealias TeamID = Int
typealias LeagueID = Int
typealias MatchID = Int
typealias PlayerID = Int


typealias MatchUniqueID = String
typealias InjuryID = String
typealias TransferID = String
typealias DateString = String


typealias MatchesByDateDictionary = [DateString: Set<MatchUniqueID>]
typealias MatchesByLeagueDictionary = [LeagueID: Set<MatchUniqueID>]


typealias MatchesByTeamDictionary = [TeamID:Set<MatchUniqueID>]
typealias InjuriesByTeamDictionary = [TeamID:Set<InjuryID>]
typealias TransfersByTeamDictionary = [TeamID:Set<TransferID>]
typealias PlayersByTeamDictionary = [TeamID:Set<PlayerID>]


typealias InjuryDictionary = [InjuryID:InjuryObject]
typealias LeagueDictionary = [LeagueID:LeagueObject]
typealias MatchesDictionary = [MatchUniqueID:MatchObject]
typealias PlayerDictionary = [PlayerID:PlayerObject]
typealias TeamDictionary = [TeamID:TeamObject]
typealias TransferDictionary = [TransferID:TransferObject]
