//
//  DataFetcher.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation

struct DataFetcher {
    static var helper = DataFetcher()
    
    func fetchDataIfValid(_ forceDataRetrieval: Bool) {
        
        // Daily Update
        if Date.now.timeIntervalSince(Saved.dailyUpdate) >= 86400 || forceDataRetrieval {
            print("\n\n*** Running daily search since time interval was - \(Date.now.timeIntervalSince(Saved.dailyUpdate))\n")
            getDataforFavoriteLeagues()
            getDataForFavoriteTeams()
            
            Saved.dailyUpdate = Date.now
        }
        
        // Weekly Update
        if Date.now.timeIntervalSince(Saved.weeklyUpdate) >= 604800 || forceDataRetrieval {
            
        }
        
        // Monthly Update
        if Date.now.timeIntervalSince(Saved.monthlyUpdate) >= 2592000 || forceDataRetrieval {
            print("\n\n*** Running monthly search since time interval was - \(Date.now.timeIntervalSince(Saved.monthlyUpdate))\n")
            Task.init {
                let leagueDictionary = try await GetLeagues.helper.getAllLeagues()
                Cached.leagueDictionary.integrate(leagueDictionary, replaceExistingValue: true)
            }
            Saved.monthlyUpdate = Date.now
        }
    }
    
    func add(team teamObject: TeamObject, with delegate: TeamDataStackDelegate) {
        
        print("DataFetcher - Adding data for team \(teamObject.name)")
        
        // Add to favorite teams list
        Cached.favoriteTeamIds.append(teamObject.id)
        
        getDataFor(team: teamObject, delegate: delegate)
    }
    
    func add(league: LeagueObject) {
        getDataFor(league: league)
    }
    
    func getMatchesForCurrentDay(completion: @escaping () -> ()) {
        Task.init {
            let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
            
            Cached.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: true)
            Cached.matchesByTeam.integrate(matchesByTeam, replaceExistingValue: true)
            Cached.matchesByDateSet.integrate(matchesByDateSet, replaceExistingValue: true)
            Cached.favoriteMatchesByDateSet.integrate(favoriteMatchesByDateSet, replaceExistingValue: true)
            Cached.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: true)
            Cached.matchesByLeagueSet.integrate(matchesByLeagueSet, replaceExistingValue: true)
            
            completion()
        }
    }
    
    // Private
    
    private func getDataforFavoriteLeagues() {
        
        print("DataFetcher - Getting data for favorite leagues")
        
        for id in Cached.favoriteLeagueIds {
            if let league = Cached.leagueDictionary[id] {
                getDataFor(league: league)
            }
        }
    }
    
    private func getDataForFavoriteTeams() {
        
        print("DataFetcher - Getting data for favorite teams")
        
        for id in Cached.favoriteTeamIds {
            if let team = Cached.teamDictionary[id] {
                getDataFor(team: team)
            }
        }
    }
    
    /*
     private func getDataFor(team: TeamObject, includeMonthly: Bool = false) {
     
     print("DataFetcher - Getting data for team \(team.name)")
     
     GetTransfers.helper.getTransfersFor(team: team.id)
     
     guard let season = team.mostRecentSeason else {
     print("WARNING - NO SEASON FOUND FOR \(team.name)")
     return}
     GetInjuries.helper.getInjuriesFor(team: team.id, season: season)
     GetMatches.helper.getMatchesFor(team: team.id, season: season)
     }
     */
    
    /*
     private func getDataFor(league: LeagueObject, new: Bool = false) {
     
     print("DataFetcher - Getting data for league \(league.name)")
     
     GetMatches.helper.getMatchesFor(league: league.id, on: Date.now)
     }
     */
    /*
     
     func add(team: TeamObject) {
     Cached.teams.append(team.id)
     let league = try await GetLeagues.helper.getLeaguesFrom(team: team.id)
     getDataFor(team: team)
     }
     */
    
    private func getDataFor(team teamObject: TeamObject, delegate: TeamDataStackDelegate? = nil) {
        Task.init {
            // Retrieve data
            let team = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
            
            Cached.teamDictionary[team.id] = team
            
            
            DispatchQueue(label: "Transfer Queue", attributes: .concurrent).async {
                Task.init {
                    let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
                    
                    if let delegate = delegate {
                        delegate.updateTransferSection(with: transfersByTeam[team.id])
                    }
                    
                    Cached.transferDictionary.integrate(transferDictionary, replaceExistingValue: true)
                    Cached.transfersByTeam.integrate(transfersByTeam, replaceExistingValue: true)
                }
            }
            
            DispatchQueue(label: "Injury Queue", attributes: .concurrent).async {
                Task.init {
                    let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
                    
                    if let delegate = delegate {
                        delegate.updateInjurySection(with: injuriesByTeam[team.id])
                    }
                    
                    Cached.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: true)
                    Cached.injuriesByTeam.integrate(injuriesByTeam, replaceExistingValue: true)
                }
            }
            
            DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
                Task.init {
                    let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
                    
                    if let delegate = delegate {
                        delegate.updateMatchSection(with: matchesByTeam[team.id])
                    }
                    
                    Cached.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: true)
                    Cached.matchesByTeam.integrate(matchesByTeam, replaceExistingValue: true)
                    Cached.matchesByDateSet.integrate(matchesByDateSet, replaceExistingValue: true)
                    Cached.favoriteMatchesByDateSet.integrate(favoriteMatchesByDateSet, replaceExistingValue: true)
                    Cached.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: true)
                    Cached.matchesByLeagueSet.integrate(matchesByLeagueSet, replaceExistingValue: true)
                }
            }
            
        }
    }
    
    private func getDataFor(league: LeagueObject)  {
        DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
            Task.init {
                let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
                
                Cached.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: true)
                Cached.matchesByTeam.integrate(matchesByTeam, replaceExistingValue: true)
                Cached.matchesByDateSet.integrate(matchesByDateSet, replaceExistingValue: true)
                Cached.favoriteMatchesByDateSet.integrate(favoriteMatchesByDateSet, replaceExistingValue: true)
                Cached.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: true)
                Cached.matchesByLeagueSet.integrate(matchesByLeagueSet, replaceExistingValue: true)
            }
        }
    }
    
    
    func testing(team: TeamID) {
        Task.init {
            if let team = Cached.teamDictionary[team] {
                print("Calling transfer async call")
                let (injuryDictionary, injuriesByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
                print(injuryDictionary, injuriesByTeam)
            }
        }
    }
}
