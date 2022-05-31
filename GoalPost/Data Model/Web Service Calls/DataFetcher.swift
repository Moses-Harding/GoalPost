//
//  DataFetcher.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation

struct DataFetcher {
    static var helper = DataFetcher()
    
    var forceDataRetrieval = true
    
    func fetchDataIfValid() {
        
        if Date.now.timeIntervalSince(Saved.lastLeaguesUpdate) >= 86400 {
            print("\n\n***\n***\n***RUNNING LEAGUE search since time interval was - \(Date.now.timeIntervalSince(Saved.lastLeaguesUpdate))\n***\n***\n***")
            GetLeagues.helper.getAllLeagues()
            getDataforFavoriteLeagues()
            getDataForFavoriteTeams()
            
            Saved.lastLeaguesUpdate = Date.now
        } else if forceDataRetrieval {
            getDataforFavoriteLeagues()
            getDataForFavoriteTeams()
        }
    }
    
    
    func getDataforFavoriteLeagues() {
        
        print("Getting data for favorite leagues")
        
        Cached.leagues.forEach { GetMatches.helper.getMatchFor(league: $0, on: Date.now) }
    }
    
    func getDataForFavoriteTeams() {
        
        print("Getting data for favorite teams")
        
        for id in Cached.teams {
            if let team = Cached.teamDictionary[id] {
                getDataFor(team: team)
            }
        }
    }
    
    func getDataFor(team: TeamObject) {
        
        let testSeason = 2021
        
        GetLeagues.helper.getLeaguesFrom(team: team.id)
        GetInjuries.helper.getInjuriesFor(team: team.id, season: testSeason)
        GetMatches.helper.getMatchFor(team: team.id, season: testSeason)
    }
}
