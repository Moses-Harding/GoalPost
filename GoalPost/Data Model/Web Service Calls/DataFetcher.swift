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
                await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true)
            }
            getDataforFavoriteLeagues(queue: queue)
            getDataForFavoriteTeams()
            return
        }
        
        if Saved.firstRun {
            
            print("\nFirst Run\n")
            
            Task.init {
                let leagueDictionary = try await GetLeagues.helper.getAllLeagues()
                
                await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true)
                
                let favoriteIds = [39, 61, 78, 135, 140]
                
                for id in favoriteIds {
                    guard let league = leagueDictionary[id] else { fatalError() }
                    await Cached.data.set(.favoriteLeaguesDictionary, with: id, to: league)
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
                await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true)
            }
            Saved.monthlyUpdate = Date.now
        }
    }
    
    func add(league: LeagueObject) {
        getDataFor(league: league)
    }
    
    func getMatchesForCurrentDay(completion: @escaping () -> ()) {
        Task.init {
            let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
            
            await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true)

            await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: matchesByTeamDictionary)
            await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary)

            await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: matchesByLeagueDictionary)
            
            completion()
        }
    }
    
    //func updateMatches(completion: (([MatchUniqueID:MatchObject]) -> ())) async throws {
    func updateMatches() async throws -> [MatchUniqueID:MatchObject] {
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
        print("Dictionaries retrieved")
        
        defer {
            Task.init {
                await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true)

                await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: matchesByTeamDictionary)
                await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary)
                await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: matchesByLeagueDictionary)
            }
        }
        
        return matchesDictionary
    }
    
    private func getDataforFavoriteLeagues(queue: DispatchQueue) {
        
        print("DataFetcher - Getting data for favorite leagues")

        Task.init {
            for league in QuickCache.helper.favoriteLeaguesDictionary {
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
                let teamIds = QuickCache.helper.favoriteTeamsDictionary.keys.map { $0 }
                while index < teamIds.count {
                    guard let team = QuickCache.helper.favoriteTeamsDictionary[teamIds[index]] else {
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
    
    private func getDataFor(team teamObject: TeamObject) async throws -> ([MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [MatchUniqueID:MatchObject], [TeamID:Set<MatchUniqueID>], [DateString: Set<MatchUniqueID>], [LeagueID: Set<MatchUniqueID>], [InjuryID:InjuryObject], [TeamID:Set<InjuryID>], [PlayerID:PlayerObject], [TeamID:Set<PlayerID>], [TransferID:TransferObject], [TeamID:Set<TransferID>]) {
        
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
        await Cached.data.set(.favoriteTeamsDictionary, with: team.id, to: team)
        await Cached.data.set(.teamDictionary, with: team.id, to: team)

        // 3. Update the league dictionary with any new information retrieved from the earlier call
        await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true)
        for (key, _) in await Cached.data.favoriteLeaguesDictionary {
            guard let league = await Cached.data.leagueDictionary[key] else { fatalError() }
            await Cached.data.set(.favoriteLeaguesDictionary, with: key, to: league)
        }

        await completion()
        
        return team
    }
    
    func addTransfersFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        await Cached.data.integrate(type: .transferDictionary, dictionary: transferDictionary, replaceExistingValue: true)
        await Cached.data.integrateSet(type: .transfersByTeamDictionary, dictionary: transfersByTeam)
        await completion()
    }
    
    func addInjuriesFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        await Cached.data.integrate(type: .injuryDictionary, dictionary: injuryDictionary, replaceExistingValue: true)
        await Cached.data.integrateSet(type: .injuriesByTeamDictionary, dictionary: injuriesByTeam)
        await completion()
    }
    
    func addSquadFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        await Cached.data.integrate(type: .playerDictionary, dictionary: playerDictionary, replaceExistingValue: true)
        await Cached.data.integrateSet(type: .playersByTeamDictionary, dictionary: playersByTeam)
        await completion()
    }
    
    func addMatchesFor(team: TeamObject, completion: @escaping () async -> ()) async throws  {
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true)
        await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByTeam)
        await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateSet)
        await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: matchesByLeagueSet)
        
        await Cached.data.integrate(type: .matchesDictionary, dictionary: lastMatchesDictionary, replaceExistingValue: true)
        await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: lastMatchesByTeam)
        await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: lastMatchesByDateSet)
        await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: lastMatchesByLeagueSet)
        
        await completion()
    }
    
    private func getDataFor(league: LeagueObject)  {
        DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
            Task.init {
                let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary) = try await GetMatches.helper.getMatchesFor(league: league)
                
                await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true)
                await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: matchesByTeamDictionary)
                await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary)
                await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: matchesByLeagueDictionary)
            }
        }
    }
    
    func search(for teamName: String, countryName: String?) async throws -> [TeamID:TeamObject] {
        let teamDictionary: [TeamID:TeamObject] = try await GetTeams.helper.search(for: teamName, countryName: countryName)
        await Cached.data.integrate(type: .teamDictionary, dictionary: teamDictionary, replaceExistingValue: true)
        
        return teamDictionary
    }
}
