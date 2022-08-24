//
//  DataFetcher.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation

struct DataFetcher {
    static var helper = DataFetcher()
    
    var testing = false
    
    func fetchDataIfValid(_ forceDataRetrieval: Bool) {
        
        let queue = DispatchQueue(label: "Get favorite data queue")
        
        if testing {
            Task.init {
                let leagueDictionary = try await GetLeagues.helper.getAllLeagues()
                await Cached.data.leagueDictionaryIntegrate(leagueDictionary, replaceExistingValue: true)
            }
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
                    await Cached.data.setFavoriteLeagues(with: id, to: leagueDictionary[id])
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
            //getDataforFavoriteLeagues(queue: queue)
            //getDataForFavoriteTeams()
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
                /*
                for (key, _) in await Cached.data.favoriteLeagues {
                    await Cached.data.setFavoriteLeagues(with: key, to: Cached.data.leagueDictionary[key])
                    await Cached.data.favoriteLeagues[key] = Cached.data.leagueDictionary[key]
                }
                 */
            }
            Saved.monthlyUpdate = Date.now
        }
    }
    
    func add(league: LeagueObject) {
        getDataFor(league: league)
    }
    
    func getMatchesForCurrentDay(completion: @escaping () -> ()) {
        Task.init {
            let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await GetMatches.helper.getMatchesFor(date: Date())
            
            await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
            await Cached.data.matchesByTeamIntegrate(matchesByTeam)
            await Cached.data.matchesByDateSetIntegrate(matchesByDateSet)

            await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet)
            
            await QuickCache.helper.updateTeams()
            await QuickCache.helper.updateLeagues()
            await QuickCache.helper.updateMatches()
            
            completion()
        }
    }
    
    //func updateMatches(completion: (([MatchUniqueID:MatchObject]) -> ())) async throws {
    func updateMatches() async throws -> [MatchUniqueID:MatchObject] {
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await GetMatches.helper.getMatchesFor(date: Date())
        print("Dictionaries retrieved")
        
        defer {
            Task.init {
                await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
                await Cached.data.matchesByTeamIntegrate(matchesByTeam)
                await Cached.data.matchesByDateSetIntegrate(matchesByDateSet)
                await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet)
                await QuickCache.helper.updateTeams()
                await QuickCache.helper.updateLeagues()
                await QuickCache.helper.updateMatches()
            }
        }
        
        return matchesDictionary
        
        //completion(matchesDictionary)

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
                let teamIds = await Cached.data.favoriteTeams.keys.map { $0 }
                while index < teamIds.count {
                    guard let team = await Cached.data.favoriteTeams[teamIds[index]] else {
                        print("DataFetcher - getDataForFavoriteTeams - Could not located team with id \(teamIds[index])")
                        continue
                    }
                    
                    try await addMatchesFor(team: team) {
                        print("DataFetcher - Added matches for \(team.name)")
                    }
                    
                    index += 1
                }
            }
        }
    }
    
    /*
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
                    
                    let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary, lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary, injuryDictionary, injuriesByTeam, playerDictionary, playersByTeam, transferDictionary, transfersByTeam) = try await getDataFor(team: team)
                    
                    await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByTeamIntegrate(matchesByTeam)
                    await Cached.data.matchesByDateSetIntegrate(matchesByDateSet)
                    await Cached.data.favoriteMatchesByDateSetIntegrate(favoriteMatchesByDateSet)
                    await Cached.data.favoriteMatchesDictionaryIntegrate(favoriteMatchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet)
                    
                    await Cached.data.matchesDictionaryIntegrate(lastMatchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByTeamIntegrate(lastMatchesByTeam)
                    await Cached.data.matchesByDateSetIntegrate(lastMatchesByDateSet)
                    await Cached.data.favoriteMatchesByDateSetIntegrate(lastFavoriteMatchesByDateSet)
                    await Cached.data.favoriteMatchesDictionaryIntegrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
                    await Cached.data.matchesByLeagueSetIntegrate(lastMatchesByLeagueSet)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Matches retrieved for \(team.name)")
                    
                    await Cached.data.injuryDictionaryIntegrate(injuryDictionary, replaceExistingValue: true)
                    await Cached.data.injuriesByTeamIntegrate(injuriesByTeam)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Injury retrieved for \(team.name)")
                    
                    await Cached.data.playerDictionaryIntegrate(playerDictionary, replaceExistingValue: true)
                    await Cached.data.playersByTeamIntegrate(playersByTeam)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Player retrieved for \(team.name)")
                    
                    await Cached.data.transferDictionaryIntegrate(transferDictionary, replaceExistingValue: true)
                    await Cached.data.transfersByTeamIntegrate(transfersByTeam)
                    
                    print("DataFetcher - getDataForFavoriteTeams - Transfer retrieved for \(team.name)")
                    
                    index += 1
                }
            }
        }
    }
    */
    
    private func getDataFor(team teamObject: TeamObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [InjuryID:InjuryObject], [TeamID:Set<InjuryID>], [PlayerID:PlayerObject], [TeamID:Set<PlayerID>], [TransferID:TransferObject], [TeamID:Set<TransferID>]) {
        
        /*
        guard let existingTeam = await Cached.data.favoriteTeams[teamObject.id] else {
            print("DataFetcher - getDataForTeam - Team with id \(teamObject.id) not added to favorites")
            fatalError()
        }
         */
        
        let team = try await DataFetcher.helper.addFavorite(team: teamObject) {}
        
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)

        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, injuryDictionary, injuriesByTeam, playerDictionary, playersByTeam, transferDictionary, transfersByTeam)
    }
    
    /* Functions for adding Team */
    
   
    func addFavorite(team teamObject: TeamObject, completion: @escaping () async -> ()) async throws -> TeamObject {
        /// Gets leagues for specified team, then adds the team to favorite dictionary, then updates league information
        
        // 1. Get updated information about the leagues the team participates in
        let (team, leagueDictionary) = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
        
        // 2. Add the team as a favorite, and update its entry in the team dictionary
        await Cached.data.setFavoriteTeams(with: team.id, to: team)
        await Cached.data.setTeamDictionary(with: team.id, to: team)

        // 3. Update the league dictionary with any new information retrieved from the earlier call
        await Cached.data.leagueDictionaryIntegrate(leagueDictionary, replaceExistingValue: true)
        for (key, _) in await Cached.data.favoriteLeagues {
            await Cached.data.setFavoriteLeagues(with: key, to: Cached.data.leagueDictionary[key])
        }
        
        await QuickCache.helper.updateTeams()
        await QuickCache.helper.updateLeagues()
        await QuickCache.helper.updateMatches()
        
        await completion()
        
        return team
    }
    
    func addTransfersFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        await Cached.data.transferDictionaryIntegrate(transferDictionary, replaceExistingValue: true)
        await Cached.data.transfersByTeamIntegrate(transfersByTeam)
        await completion()
        
        await QuickCache.helper.updateTeams()
        await QuickCache.helper.updateLeagues()
        await QuickCache.helper.updateMatches()
    }
    
    func addInjuriesFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        await Cached.data.injuryDictionaryIntegrate(injuryDictionary, replaceExistingValue: true)
        await Cached.data.injuriesByTeamIntegrate(injuriesByTeam)
        await completion()
        
        await QuickCache.helper.updateTeams()
        await QuickCache.helper.updateLeagues()
        await QuickCache.helper.updateMatches()
    }
    
    func addSquadFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        await Cached.data.playerDictionaryIntegrate(playerDictionary, replaceExistingValue: true)
        await Cached.data.playersByTeamIntegrate(playersByTeam)
        await completion()
        
        await QuickCache.helper.updateTeams()
        await QuickCache.helper.updateLeagues()
        await QuickCache.helper.updateMatches()
    }
    
    func addMatchesFor(team: TeamObject, completion: @escaping () async -> ()) async throws  {
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
        await Cached.data.matchesByTeamIntegrate(matchesByTeam)
        await Cached.data.matchesByDateSetIntegrate(matchesByDateSet)
        await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet)
        
        await Cached.data.matchesDictionaryIntegrate(lastMatchesDictionary, replaceExistingValue: true)
        await Cached.data.matchesByTeamIntegrate(lastMatchesByTeam)
        await Cached.data.matchesByDateSetIntegrate(lastMatchesByDateSet)
        await Cached.data.matchesByLeagueSetIntegrate(lastMatchesByLeagueSet)
        
        await QuickCache.helper.updateTeams()
        await QuickCache.helper.updateLeagues()
        await QuickCache.helper.updateMatches()
        
        await completion()
    }
    
    private func getDataFor(league: LeagueObject)  {
        DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
            Task.init {
                let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await GetMatches.helper.getMatchesFor(league: league)
                
                await Cached.data.matchesDictionaryIntegrate(matchesDictionary, replaceExistingValue: true)
                await Cached.data.matchesByTeamIntegrate(matchesByTeam)
                await Cached.data.matchesByDateSetIntegrate(matchesByDateSet)
                await Cached.data.matchesByLeagueSetIntegrate(matchesByLeagueSet)
                
                await QuickCache.helper.updateTeams()
                await QuickCache.helper.updateLeagues()
                await QuickCache.helper.updateMatches()
            }
        }
    }
    
    func search(for teamName: String, countryName: String?) async throws -> [TeamID:TeamObject] {
        let teamDictionary: [TeamID:TeamObject] = try await GetTeams.helper.search(for: teamName, countryName: countryName)
        await Cached.data.teamDictionaryIntegrate(teamDictionary, replaceExistingValue: true)
        
        return teamDictionary
    }
}
