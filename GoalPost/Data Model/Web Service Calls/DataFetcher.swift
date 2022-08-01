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
                
                await Cached.data.leagueDictionaryIntegrate(leagueDictionary, replaceExistingValue: true)
                
                let favoriteIds = [39, 61, 78, 135, 140]
                
                for id in favoriteIds {
                    await await Cached.data.setFavoriteLeagues(with: id, to: leagueDictionary[id])
                }
                
                // MARK: NOTE - ENABLE THIS IN PROD
                /*
                 for league in await Cached.data.favoriteLeagues {
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
                await Cached.data.leagueDictionaryIntegrate(leagueDictionary, replaceExistingValue: true)
                for (key, _) in await Cached.data.favoriteLeagues {
                    await Cached.data.setFavoriteLeagues(with: key, to: Cached.data.leagueDictionary[key])
                    //await Cached.data.favoriteLeagues[key] = Cached.data.leagueDictionary[key]
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
            
            await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
            await Cached.data.matchesByTeamIntegrate(matchesByTeam, replaceExistingValue: true)
            await Cached.data.matchesByDateSetIntegrate(matchesByDateSet, replaceExistingValue: true)
            await Cached.data.favoriteMatchesByDateSetIntegrate(favoriteMatchesByDateSet, replaceExistingValue: true)
            await Cached.data.favoriteMatchesDictionaryIntegrate(favoriteMatchesDictionary, replaceExistingValue: true)
            await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet, replaceExistingValue: true)
            
            completion()
        }
    }
    
    private func getDataforFavoriteLeagues(queue: DispatchQueue) {
        
        print("DataFetcher - Getting data for favorite leagues")

        Task.init {
        for league in await Cached.data.getFavoriteLeagues() {
            queue.async {
                getDataFor(league: league.value)
            }
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
                var teamIds = await Cached.data.favoriteTeams.keys.map { $0 }
                while index < teamIds.count {
                    //queue.async {
                    //Task.init {
                    guard let team = await Cached.data.favoriteTeams[teamIds[index]] else {
                        print("DataFetcher - getDataForFavoriteTeams - Could not located team with id \(teamIds[index])")
                        continue
                    }
                    
                    print("DataFetcher - getDataForFavoriteTeams - Beginning data retrival for team \(team.name)")
                    
                    let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary, lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary, injuryDictionary, injuriesByTeam, playerDictionary, playersByTeam, transferDictionary, transfersByTeam) = try await getDataFor(team: team, group: group)
                    
                    await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByTeamIntegrate(matchesByTeam, replaceExistingValue: true)
                    await Cached.data.matchesByDateSetIntegrate(matchesByDateSet, replaceExistingValue: true)
                    await Cached.data.favoriteMatchesByDateSetIntegrate(favoriteMatchesByDateSet, replaceExistingValue: true)
                    await Cached.data.favoriteMatchesDictionaryIntegrate(favoriteMatchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet, replaceExistingValue: true)
                    
                    await Cached.data.matchesDictionaryIntegrate(lastMatchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByTeamIntegrate(lastMatchesByTeam, replaceExistingValue: true)
                    await Cached.data.matchesByDateSetIntegrate(lastMatchesByDateSet, replaceExistingValue: true)
                    await Cached.data.favoriteMatchesByDateSetIntegrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
                    await Cached.data.favoriteMatchesDictionaryIntegrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByLeagueSetIntegrate(lastMatchesByLeagueSet, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Matches retrieved for \(team.name)")
                    
                    await Cached.data.injuryDictionaryIntegrate(injuryDictionary, replaceExistingValue: true)
                    await Cached.data.injuriesByTeamIntegrate(injuriesByTeam, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Injury retrieved for \(team.name)")
                    
                    await Cached.data.playerDictionaryIntegrate(playerDictionary, replaceExistingValue: true)
                    await Cached.data.playersByTeamIntegrate(playersByTeam, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Player retrieved for \(team.name)")
                    
                    await Cached.data.transferDictionaryIntegrate(transferDictionary, replaceExistingValue: true)
                    await Cached.data.transfersByTeamIntegrate(transfersByTeam, replaceExistingValue: true)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Transfer retrieved for \(team.name)")
                    
                    index += 1
                }
            }
        }
    }
    
    private func getDataFor(team teamObject: TeamObject, group: DispatchGroup) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject], [MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [MatchUniqueID:MatchObject], [InjuryID:InjuryObject], [TeamID:Set<InjuryID>], [PlayerID:PlayerObject], [TeamID:Set<PlayerID>], [TransferID:TransferObject], [TeamID:Set<TransferID>]) {
        
        let team = try await DataFetcher.helper.addLeaguesFor(team: teamObject) {}
        
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
     
     for team in await Cached.data.favoriteTeams {
     
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
     
     
     await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
     await Cached.data.matchesByTeamIntegrate(matchesByTeam, replaceExistingValue: true)
     await Cached.data.matchesByDateSetIntegrate(matchesByDateSet, replaceExistingValue: true)
     await Cached.data.favoriteMatchesByDateSetIntegrate(favoriteMatchesByDateSet, replaceExistingValue: true)
     await Cached.data.favoriteMatchesDictionaryIntegrate(favoriteMatchesDictionary, replaceExistingValue: true)
     await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet, replaceExistingValue: true)
     
     await Cached.data.matchesDictionaryIntegrate(lastMatchesDictionary, replaceExistingValue: true)
     await Cached.data.matchesByTeamIntegrate(lastMatchesByTeam, replaceExistingValue: true)
     await Cached.data.matchesByDateSetIntegrate(lastMatchesByDateSet, replaceExistingValue: true)
     await Cached.data.favoriteMatchesByDateSetIntegrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
     await Cached.data.favoriteMatchesDictionaryIntegrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
     await Cached.data.matchesByLeagueSetIntegrate(lastMatchesByLeagueSet, replaceExistingValue: true)
     
     print("Matches complete for \(team.name)")
     
     let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
     
     await Cached.data.injuryDictionaryIntegrate(injuryDictionary, replaceExistingValue: true)
     await Cached.data.injuriesByTeamIntegrate(injuriesByTeam, replaceExistingValue: true)
     
     print("Injury complete for \(team.name)")
     
     let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
     
     await Cached.data.playerDictionaryIntegrate(playerDictionary, replaceExistingValue: true)
     await Cached.data.playersByTeamIntegrate(playersByTeam, replaceExistingValue: true)
     
     print("Player complete for \(team.name)")
     
     let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
     await Cached.data.transferDictionaryIntegrate(transferDictionary, replaceExistingValue: true)
     await Cached.data.transfersByTeamIntegrate(transfersByTeam, replaceExistingValue: true)
     print("Transfer complete for \(team.name)")
     
     group.leave()
     }
     }
     */
    
    /* Functions for adding Team */
    
    func addLeaguesFor(team teamObject: TeamObject, completion: @escaping () async -> ()) async throws -> TeamObject {
        
        let (team, leagueDictionary) = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
        
        await Cached.data.setFavoriteTeams(with: team.id, to: team)
        await Cached.data.setTeamDictionary(with: team.id, to: team)

        await Cached.data.leagueDictionaryIntegrate(leagueDictionary, replaceExistingValue: true)
        for (key, _) in await Cached.data.favoriteLeagues {
            await Cached.data.setFavoriteLeagues(with: key, to: Cached.data.leagueDictionary[key])
        }
        
        await completion()
        
        return team
    }
    
    func addTransfersFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        await Cached.data.transferDictionaryIntegrate(transferDictionary, replaceExistingValue: true)
        await Cached.data.transfersByTeamIntegrate(transfersByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func addInjuriesFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        await Cached.data.injuryDictionaryIntegrate(injuryDictionary, replaceExistingValue: true)
        await Cached.data.injuriesByTeamIntegrate(injuriesByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func addSquadFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        await Cached.data.playerDictionaryIntegrate(playerDictionary, replaceExistingValue: true)
        await Cached.data.playersByTeamIntegrate(playersByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func addMatchesFor(team: TeamObject, completion: @escaping () async -> ()) async throws  {
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        
        
        await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
        await Cached.data.matchesByTeamIntegrate(matchesByTeam, replaceExistingValue: true)
        await Cached.data.matchesByDateSetIntegrate(matchesByDateSet, replaceExistingValue: true)
        await Cached.data.favoriteMatchesByDateSetIntegrate(favoriteMatchesByDateSet, replaceExistingValue: true)
        await Cached.data.favoriteMatchesDictionaryIntegrate(favoriteMatchesDictionary, replaceExistingValue: true)
        await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet, replaceExistingValue: true)
        
        await Cached.data.matchesDictionaryIntegrate(lastMatchesDictionary, replaceExistingValue: true)
        await Cached.data.matchesByTeamIntegrate(lastMatchesByTeam, replaceExistingValue: true)
        await Cached.data.matchesByDateSetIntegrate(lastMatchesByDateSet, replaceExistingValue: true)
        await Cached.data.favoriteMatchesByDateSetIntegrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
        await Cached.data.favoriteMatchesDictionaryIntegrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
        await Cached.data.matchesByLeagueSetIntegrate(lastMatchesByLeagueSet, replaceExistingValue: true)
        
        await completion()
    }
    
    private func getDataFor(league: LeagueObject)  {
        DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
            Task.init {
                let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getMatchesFor(league: league)
                
                await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
                await Cached.data.matchesByTeamIntegrate(matchesByTeam, replaceExistingValue: true)
                await Cached.data.matchesByDateSetIntegrate(matchesByDateSet, replaceExistingValue: true)
                await Cached.data.favoriteMatchesByDateSetIntegrate(favoriteMatchesByDateSet, replaceExistingValue: true)
                await Cached.data.favoriteMatchesDictionaryIntegrate(favoriteMatchesDictionary, replaceExistingValue: true)
                await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet, replaceExistingValue: true)
            }
        }
    }
}
