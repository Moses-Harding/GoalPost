//
//  DataFetcher.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation

struct DataFetcher {
    static var helper = DataFetcher()
    
    var suppressDataRetrieval = false
    
    func fetchDataIfValid() {
    
        guard Testing.manager.getLiveData else {
            print("DataFetcher - FetchDataIfValid - Live data retrieval disabled")
            return }
        
        let queue = DispatchQueue(label: "Get favorite data queue")

        
        if Saved.firstRun {
            
            print("\nFirst Run\n")
            
            Task.init {
                let leagueDictionary = try await GetLeagues.helper.getAllLeagues()
                
                await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true, calledBy: "DataFetcher - FetchDataIfValid")
                
                let favoriteIds = [39, 61, 78, 135, 140]
                
                for id in favoriteIds {
                    guard let league = leagueDictionary[id] else { fatalError() }
                    await Cached.data.set(.favoriteLeaguesDictionary, with: id, to: league, calledBy: "DataFetcher - FetchDataIfValid")
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
        if Date.now.timeIntervalSince(Saved.dailyUpdate) >= 86400 && !suppressDataRetrieval {
            print("\n\n*** Running daily search since time interval was - \(Date.now.timeIntervalSince(Saved.dailyUpdate))\n")
            Saved.dailyUpdate = Date.now
            getDataforFavoriteLeagues(queue: queue)
            getDataForFavoriteTeams(queue: queue)
        }
        
        // Weekly Update
        if Date.now.timeIntervalSince(Saved.weeklyUpdate) >= 604800 && !suppressDataRetrieval {
            
        }
        
        // Monthly Update
        if Date.now.timeIntervalSince(Saved.monthlyUpdate) >= 2592000 && !suppressDataRetrieval {
            print("\n\n*** Running monthly search since time interval was - \(Date.now.timeIntervalSince(Saved.monthlyUpdate))\n")
            Task.init {
                let leagueDictionary = try await GetLeagues.helper.getAllLeagues()
                await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true, calledBy: "DataFetcher - FetchDataIfValid")
            }
            Saved.monthlyUpdate = Date.now
        }
    }
    
}

// MARK: Get Data For Favorites
extension DataFetcher {
    
    
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
    
    private func getDataForFavoriteTeams(queue: DispatchQueue) {
        
        print("DataFetcher - Getting data for favorite teams")
        
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
                    
                    index += 1
                    
                    let favoriteLeagueSet = Set<LeagueID>(QuickCache.helper.favoriteLeaguesDictionary.keys)
                    if team.leagueSet.isSubset(of: favoriteLeagueSet) {
                        print("DataFetcher - \(team.name) is not being updated because its league set is a subset of favorite leagues")
                        continue
                    } else {
                        
                        try await addMatchesFor(team: team) {
                            print("DataFetcher - Added matches for \(team.name)")
                        }
                    }
                    
                }
            }
        }
    }
    
    
    func add(league: LeagueObject) {
        getDataFor(league: league)
    }
    
    func getMatchesForCurrentDay(completion: @escaping () -> ()) {
        Task.init {
            let (matchesDictionary, matchesByDateDictionary, matchIdDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
            
            await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true, calledBy: "DataFetcher - GetMatchesForCurrentDay")
            
            await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary, calledBy: "DataFetcher - GetMatchesForCurrentDay")
            
            await Cached.data.integrate(type: .matchIdDictionary, dictionary: matchIdDictionary, replaceExistingValue: true, calledBy: "DataFetcher - GetMatchesForCurrentDay")
            
            completion()
        }
    }
    

    func updateMatches() async throws {
        let (matchesDictionary, matchesByDateDictionary, matchIdDictionary) = try await GetMatches.helper.getMatchesFor(date: Date())
        await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true, calledBy: "DataFetcher - UpdateMatches")
        await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary, calledBy: "DataFetcher - UpdateMatches")
        await Cached.data.integrate(type: .matchIdDictionary, dictionary: matchIdDictionary, replaceExistingValue: true, calledBy: "DataFetcher - UpdateMatches")
    }
    
    private func getDataFor(team teamObject: TeamObject) async throws ->
    (MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary,
     MatchesDictionary, MatchesByTeamDictionary, MatchesByDateDictionary, MatchesByLeagueDictionary, MatchIdDictionary,
     InjuryDictionary, InjuriesByTeamDictionary,
     PlayerDictionary, PlayersByTeamDictionary,
     TransferDictionary, TransfersByTeamDictionary) {
        
        let team = try await DataFetcher.helper.addFavorite(team: teamObject) {}
        
        let (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, matchIdDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastMatchIdDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        return (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, matchIdDictionary, lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastMatchIdDictionary, injuryDictionary, injuriesByTeam, playerDictionary, playersByTeam, transferDictionary, transfersByTeam)
    }
    
    func getEvents(for matchId: MatchID, completion: @escaping ([EventObject]) -> ()) async throws {
        
        let matchesDictionary = try await GetEvents.helper.getEventsFor(match: matchId)
        
        guard let match = matchesDictionary[matchId] else { fatalError("DataFetcher - GetEvents - Match Not Retrieved") }
        completion(match.events)
        
        await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true, calledBy: "DataFetcher - GetEvents")
    }
    
    /* Functions for adding Team */
    
    
    func addFavorite(team teamObject: TeamObject, completion: @escaping () async -> ()) async throws -> TeamObject {
        /// Gets leagues for specified team, then adds the team to favorite dictionary, then updates league information
        
        // 1. Get updated information about the leagues the team participates in
        let (team, leagueDictionary) = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
        
        // 2. Add the team as a favorite, and update its entry in the team dictionary
        await Cached.data.set(.favoriteTeamsDictionary, with: team.id, to: team, calledBy: "DataFetcher - AddFavoriteTeam")
        await Cached.data.set(.teamDictionary, with: team.id, to: team, calledBy: "DataFetcher - AddFavoriteTeam")
        
        // 3. Update the league dictionary with any new information retrieved from the earlier call
        await Cached.data.integrate(type: .leagueDictionary, dictionary: leagueDictionary, replaceExistingValue: true, calledBy: "DataFetcher - AddFavoriteTeam")
        for (key, _) in await Cached.data.favoriteLeaguesDictionary {
            guard let league = await Cached.data.leagueDictionary[key] else { fatalError() }
            await Cached.data.set(.favoriteLeaguesDictionary, with: key, to: league, calledBy: "DataFetcher - AddFavoriteTeam")
        }
        
        return team
    }
    
    func addTransfersFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        
        await Cached.data.integrate(type: .transferDictionary, dictionary: transferDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Transfers For")
        await Cached.data.integrateSet(type: .transfersByTeamDictionary, dictionary: transfersByTeam, calledBy: "DataFetcher - Add Transfers For")
        await completion()
    }
    
    func addInjuriesFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        await Cached.data.integrate(type: .injuryDictionary, dictionary: injuryDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Injuries For")
        await Cached.data.integrateSet(type: .injuriesByTeamDictionary, dictionary: injuriesByTeam, calledBy: "DataFetcher - Add Injuries For")
        await completion()
    }
    
    func addSquadFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (playerDictionary, playersByTeam) = try await GetSquad.helper.getSquadFor(team: team)
        
        await Cached.data.integrate(type: .playerDictionary, dictionary: playerDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Squad For")
        await Cached.data.integrateSet(type: .playersByTeamDictionary, dictionary: playersByTeam, calledBy: "DataFetcher - Add Quad For")
        await completion()
    }
    
    func addMatchesFor(team: TeamObject, completion: @escaping () async -> ()) async throws  {
        let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
        let (lastMatchesDictionary, lastMatchesByTeamDictionary, lastMatchesByDateDictionary, lastMatchesByLeagueDictionary, lastMatchIdDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
        
        await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: matchesByTeamDictionary, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: matchesByLeagueDictionary, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrate(type: .matchIdDictionary, dictionary: matchIdDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Matches For")
        
        await Cached.data.integrate(type: .matchesDictionary, dictionary: lastMatchesDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: lastMatchesByTeamDictionary, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: lastMatchesByDateDictionary, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: lastMatchesByLeagueDictionary, calledBy: "DataFetcher - Add Matches For")
        await Cached.data.integrate(type: .matchIdDictionary, dictionary: lastMatchIdDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Add Matches For")
        
        await completion()
    }
    
    func getDataFor(league: LeagueObject, completion: (() -> ())? = nil)  {
        DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
            Task.init {
                let (matchesDictionary, matchesByTeamDictionary, matchesByDateDictionary, matchesByLeagueDictionary, matchIdDictionary) = try await GetMatches.helper.getMatchesFor(league: league)
                
                await Cached.data.integrate(type: .matchesDictionary, dictionary: matchesDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Get Data For")
                await Cached.data.integrateSet(type: .matchesByTeamDictionary, dictionary: matchesByTeamDictionary, calledBy: "DataFetcher - Get Data For")
                await Cached.data.integrateSet(type: .matchesByDateDictionary, dictionary: matchesByDateDictionary, calledBy: "DataFetcher - Get Data For")
                await Cached.data.integrateSet(type: .matchesByLeagueDictionary, dictionary: matchesByLeagueDictionary, calledBy: "DataFetcher - Get Data For")
                await Cached.data.integrate(type: .matchIdDictionary, dictionary: matchIdDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Get Data For")
                
                if let completion = completion { completion() }
            }
        }
    }
    
    func search(for teamName: String, countryName: String?) async throws -> TeamDictionary {
        let teamDictionary = try await GetTeams.helper.search(for: teamName, countryName: countryName)
        await Cached.data.integrate(type: .teamDictionary, dictionary: teamDictionary, replaceExistingValue: true, calledBy: "DataFetcher - Search For")
        
        return teamDictionary
    }
}
