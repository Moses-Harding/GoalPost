//
//  DataFetcher.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation

struct DataFetcher {
    static var helper = DataFetcher()
    
    var testing = true
    
    func fetchDataIfValid(_ forceDataRetrieval: Bool) {
        
        let queue = DispatchQueue(label: "Get favorite data queue")
        
        if testing {
            getDataforFavoriteLeagues(queue: queue)
            getDataForFavoriteTeams()
            return
        }
        
        if Saved.firstRun {
            
            print("\nFirst Run\n")
            
            Task.init {
                let leagueDictionary = try await GetLeagues.helper.getAllLeagues()
                Cached.leagueDictionary.integrate(leagueDictionary, replaceExistingValue: true)
                
                let favoriteIds = [39, 61, 78, 135, 140]
                
                for id in favoriteIds {
                    Cached.favoriteLeagues[id] = leagueDictionary[id]
                }
                
                // MARK: NOTE - ENABLE THIS IN PROD
                /*
                 for league in Cached.favoriteLeagues {
                 group.enter()
                 self.getDataFor(league: league.value)
                 group.leave()
                 }
                 */
            }
            
            Saved.firstRun = false
            
            return
        }
        
        // Daily Update
        if Date.now.timeIntervalSince(Saved.dailyUpdate) >= 86400 || forceDataRetrieval {
            print("\n\n*** Running daily search since time interval was - \(Date.now.timeIntervalSince(Saved.dailyUpdate))\n")
            getDataforFavoriteLeagues(queue: queue)
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
                for (key, _) in Cached.favoriteLeagues {
                    Cached.favoriteLeagues[key] = Cached.leagueDictionary[key]
                }
            }
            Saved.monthlyUpdate = Date.now
        }
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
    
    private func getDataforFavoriteLeagues(queue: DispatchQueue) {
        
        print("DataFetcher - Getting data for favorite leagues")
        
        for league in Cached.favoriteLeagues {
            queue.async {
                getDataFor(league: league.value)
            }
        }
    }
    
    private func getDataForFavoriteTeams() {
        
        print("DataFetcher - Getting data for favorite teams")
        
        let queue = DispatchQueue(label: "favoriteTeamQueue", qos: .background)
        
        let group = DispatchGroup()
        group.setTarget(queue: queue)
        
        queue.async {
            Task.init {
                var index = 0
                var teamIds = Cached.favoriteTeams.keys.map { $0 }
                while index < teamIds.count {
                    //queue.async {
                    //Task.init {
                    guard let team = Cached.favoriteTeams[teamIds[index]] else {
                        print("DataFetcher - getDataForFavoriteTeams - Could not located team with id \(teamIds[index])")
                        continue
                    }
                    
                    print("DataFetcher - getDataForFavoriteTeams - Beginning data retrival for team \(team.name)")
                    
                    let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary, lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary, injuryDictionary, injuriesByTeam, playerDictionary, playersByTeam, transferDictionary, transfersByTeam) = try await getDataFor(team: team, group: group)
                    
                    Cached.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: true)
                    Cached.matchesByTeam.integrate(matchesByTeam, replaceExistingValue: true)
                    Cached.matchesByDateSet.integrate(matchesByDateSet, replaceExistingValue: true)
                    Cached.favoriteMatchesByDateSet.integrate(favoriteMatchesByDateSet, replaceExistingValue: true)
                    Cached.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: true)
                    Cached.matchesByLeagueSet.integrate(matchesByLeagueSet, replaceExistingValue: true)
                    
                    Cached.matchesDictionary.integrate(lastMatchesDictionary, replaceExistingValue: true)
                    Cached.matchesByTeam.integrate(lastMatchesByTeam, replaceExistingValue: true)
                    Cached.matchesByDateSet.integrate(lastMatchesByDateSet, replaceExistingValue: true)
                    Cached.favoriteMatchesByDateSet.integrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
                    Cached.favoriteMatchesDictionary.integrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
                    Cached.matchesByLeagueSet.integrate(lastMatchesByLeagueSet, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Matches retrieved for \(team.name)")
                    
                    Cached.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: true)
                    Cached.injuriesByTeam.integrate(injuriesByTeam, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Injury retrieved for \(team.name)")
                    
                    Cached.playerDictionary.integrate(playerDictionary, replaceExistingValue: true)
                    Cached.playersByTeam.integrate(playersByTeam, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Player retrieved for \(team.name)")
                    
                    Cached.transferDictionary.integrate(transferDictionary, replaceExistingValue: true)
                    Cached.transfersByTeam.integrate(transfersByTeam, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Transfer retrieved for \(team.name)")
                    
                    index += 1
                }
            }
        }
    }
    
    private func getDataFor(team teamObject: TeamObject, group: DispatchGroup) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject], [MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject], [InjuryID:InjuryObject], [TeamID:Set<InjuryID>], [PlayerID:PlayerObject], [TeamID:Set<PlayerID>], [TransferID:TransferObject], [TeamID:Set<TransferID>]) {
        
        let team = try await DataFetcher.helper.addLeaguesFor(team: teamObject)
        
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary, lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary, injuryDictionary, injuriesByTeam, playerDictionary, playersByTeam, transferDictionary, transfersByTeam)
        
    }
    
    /*
     private func getDataForFavoriteTeams() {
     
     print("DataFetcher - Getting data for favorite teams")
     
     let queue = DispatchQueue(label: "favoriteTeamQueue", qos: .background)
     
     let group = DispatchGroup()
     group.setTarget(queue: queue)
     
     for team in Cached.favoriteTeams {
     
     group.enter()
     getDataFor(team: team.value, group: group)
     group.wait()
     }
     }
     
     private func getDataFor(team teamObject: TeamObject, group: DispatchGroup) {
     
     Task.init {
     let team = try await DataFetcher.helper.addLeaguesFor(team: teamObject)
     
     let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
     let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
     
     
     Cached.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: true)
     Cached.matchesByTeam.integrate(matchesByTeam, replaceExistingValue: true)
     Cached.matchesByDateSet.integrate(matchesByDateSet, replaceExistingValue: true)
     Cached.favoriteMatchesByDateSet.integrate(favoriteMatchesByDateSet, replaceExistingValue: true)
     Cached.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: true)
     Cached.matchesByLeagueSet.integrate(matchesByLeagueSet, replaceExistingValue: true)
     
     Cached.matchesDictionary.integrate(lastMatchesDictionary, replaceExistingValue: true)
     Cached.matchesByTeam.integrate(lastMatchesByTeam, replaceExistingValue: true)
     Cached.matchesByDateSet.integrate(lastMatchesByDateSet, replaceExistingValue: true)
     Cached.favoriteMatchesByDateSet.integrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
     Cached.favoriteMatchesDictionary.integrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
     Cached.matchesByLeagueSet.integrate(lastMatchesByLeagueSet, replaceExistingValue: true)
     
     print("Matches complete for \(team.name)")
     
     let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
     
     Cached.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: true)
     Cached.injuriesByTeam.integrate(injuriesByTeam, replaceExistingValue: true)
     
     print("Injury complete for \(team.name)")
     
     let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
     
     Cached.playerDictionary.integrate(playerDictionary, replaceExistingValue: true)
     Cached.playersByTeam.integrate(playersByTeam, replaceExistingValue: true)
     
     print("Player complete for \(team.name)")
     
     let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
     Cached.transferDictionary.integrate(transferDictionary, replaceExistingValue: true)
     Cached.transfersByTeam.integrate(transfersByTeam, replaceExistingValue: true)
     print("Transfer complete for \(team.name)")
     
     group.leave()
     }
     }
     */
    
    /* Functions for adding Team */
    
    func addLeaguesFor(team teamObject: TeamObject) async throws -> TeamObject {
        
        let (team, leagueDictionary) = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
        
        Cached.favoriteTeams[team.id] = team
        Cached.teamDictionary[team.id] = team
        
        Cached.leagueDictionary.integrate(leagueDictionary, replaceExistingValue: true)
        for (key, _) in Cached.favoriteLeagues {
            Cached.favoriteLeagues[key] = Cached.leagueDictionary[key]
        }
        
        return team
    }
    
    func addTransfersFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        Cached.transferDictionary.integrate(transferDictionary, replaceExistingValue: true)
        Cached.transfersByTeam.integrate(transfersByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func addInjuriesFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        Cached.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: true)
        Cached.injuriesByTeam.integrate(injuriesByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func addSquadFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        Cached.playerDictionary.integrate(playerDictionary, replaceExistingValue: true)
        Cached.playersByTeam.integrate(playersByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func addMatchesFor(team: TeamObject, completion: @escaping () async -> ()) async throws  {
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        
        
        Cached.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: true)
        Cached.matchesByTeam.integrate(matchesByTeam, replaceExistingValue: true)
        Cached.matchesByDateSet.integrate(matchesByDateSet, replaceExistingValue: true)
        Cached.favoriteMatchesByDateSet.integrate(favoriteMatchesByDateSet, replaceExistingValue: true)
        Cached.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: true)
        Cached.matchesByLeagueSet.integrate(matchesByLeagueSet, replaceExistingValue: true)
        
        Cached.matchesDictionary.integrate(lastMatchesDictionary, replaceExistingValue: true)
        Cached.matchesByTeam.integrate(lastMatchesByTeam, replaceExistingValue: true)
        Cached.matchesByDateSet.integrate(lastMatchesByDateSet, replaceExistingValue: true)
        Cached.favoriteMatchesByDateSet.integrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
        Cached.favoriteMatchesDictionary.integrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
        Cached.matchesByLeagueSet.integrate(lastMatchesByLeagueSet, replaceExistingValue: true)
        
        await completion()
    }
    
    private func getDataFor(league: LeagueObject)  {
        DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
            Task.init {
                let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getMatchesFor(league: league)
                
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
