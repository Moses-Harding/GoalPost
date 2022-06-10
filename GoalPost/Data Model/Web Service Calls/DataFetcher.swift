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
                    self.getDataFor(league: league.value)
                }
                */
            }
            
            Saved.firstRun = false
            
            return
        }
        
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
                for (key, _) in Cached.favoriteLeagues {
                    Cached.favoriteLeagues[key] = Cached.leagueDictionary[key]
                }
            }
            Saved.monthlyUpdate = Date.now
        }
    }
    
    func add(team teamObject: TeamObject) {
        
        print("DataFetcher - Adding data for team \(teamObject.name)")
        
        getDataFor(team: teamObject)
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
        
        for league in Cached.favoriteLeagues {
            getDataFor(league: league.value)
        }
    }
    
    private func getDataForFavoriteTeams() {
        
        print("DataFetcher - Getting data for favorite teams")
        
        for team in Cached.favoriteTeams {
            getDataFor(team: team.value)
        }
    }
    
    private func getDataFor(team teamObject: TeamObject) {
        Task.init {
            // Retrieve data
            let (team, leagueDictionary) = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
            
            Cached.favoriteTeams[team.id] = team
            Cached.teamDictionary[team.id] = team
            Cached.leagueDictionary.integrate(leagueDictionary, replaceExistingValue: true)
            for (key, _) in Cached.favoriteLeagues {
                Cached.favoriteLeagues[key] = Cached.leagueDictionary[key]
            }
            
            DispatchQueue(label: "Transfer Queue", attributes: .concurrent).async {
                Task.init {
                    let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)

                    
                    Cached.transferDictionary.integrate(transferDictionary, replaceExistingValue: true)
                    Cached.transfersByTeam.integrate(transfersByTeam, replaceExistingValue: true)
                }
            }
            
            DispatchQueue(label: "Injury Queue", attributes: .concurrent).async {
                Task.init {
                    let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
                    
                    
                    Cached.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: true)
                    Cached.injuriesByTeam.integrate(injuriesByTeam, replaceExistingValue: true)
                }
            }
            
            DispatchQueue(label: "Match Queue", attributes: .concurrent).async {
                Task.init {
                    var (matchesDictionary, matchesByTeam, matchesByDateSet, matchesByLeagueSet, favoriteMatchesByDateSet, favoriteMatchesDictionary) = try await GetMatches.helper.getNextMatchesFor(team: team, numberOfMatches: 30)
                    let (lastMatchesDictionary, lastMatchesByTeam, lastMatchesByDateSet, lastMatchesByLeagueSet, lastFavoriteMatchesByDateSet, lastFavoriteMatchesDictionary) = try await GetMatches.helper.getLastMatchesFor(team: team, numberOfMatches: 30)
                    
                    matchesDictionary.integrate(lastMatchesDictionary, replaceExistingValue: true)
                    matchesByTeam.integrate(lastMatchesByTeam, replaceExistingValue: true)
                    matchesByDateSet.integrate(lastMatchesByDateSet, replaceExistingValue: true)
                    favoriteMatchesByDateSet.integrate(lastFavoriteMatchesByDateSet, replaceExistingValue: true)
                    favoriteMatchesDictionary.integrate(lastFavoriteMatchesDictionary, replaceExistingValue: true)
                    matchesByLeagueSet.integrate(lastMatchesByLeagueSet, replaceExistingValue: true)
                    
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
    
    func getLeaguesFor(team teamObject: TeamObject) async throws -> TeamObject {
        
        let (team, leagueDictionary) = try await GetLeagues.helper.getLeaguesFrom(team: teamObject)
        
        Cached.favoriteTeams[team.id] = team
        Cached.teamDictionary[team.id] = team
        Cached.leagueDictionary.integrate(leagueDictionary, replaceExistingValue: true)
        for (key, _) in Cached.favoriteLeagues {
            Cached.favoriteLeagues[key] = Cached.leagueDictionary[key]
        }
        
        return team
    }
    
    func getTransfersFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (transferDictionary, transfersByTeam) = try await GetTransfers.helper.getTransfersFor(team: team)
        Cached.transferDictionary.integrate(transferDictionary, replaceExistingValue: true)
        Cached.transfersByTeam.integrate(transfersByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func getInjuriesFor(team: TeamObject, completion: @escaping () async -> ()) async throws {
        let (injuryDictionary, injuriesByTeam) = try await GetInjuries.helper.getInjuriesFor(team: team)
        
        Cached.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: true)
        Cached.injuriesByTeam.integrate(injuriesByTeam, replaceExistingValue: true)
        await completion()
    }
    
    func getMatchesFor(team: TeamObject, completion: @escaping () async -> ()) async throws  {
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
