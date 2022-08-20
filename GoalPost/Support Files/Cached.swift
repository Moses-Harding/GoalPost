//
//  UserSettings.swift
//  GoalPost
//
//  Created by Moses Harding on 5/4/22.
//

// More on property wrappers - https://www.swiftbysundell.com/articles/property-wrappers-in-swift/

import Foundation
import UIKit

@propertyWrapper
// Create a structure that take generic types that are codable
struct Storage<T: Codable> {
    // The key is the key used for UserDefaults
    let key: String
    // A default value is needed so that the user doesn't retrieve a nil value
    let defaultValue: T
    
    // Variable must be initialized with a key
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    // WrappedValue is required for a propertyWrapper - this is the value that is going to be wrapped. In this case, it's generic (codable)
    var wrappedValue: T {
        get {
            // If a value exists, return it as Data, else return nil
            guard let data =  UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            
            // Convert it from Data to whatever type it is
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            // Convert newValue to Data because we're storing a generic value. Since we don't know what type it's going to be, we need the JSONDecoder to convert it to the appropraite type, and JSONDecoder requires "Data".
            let data = try? JSONEncoder().encode(newValue)
            
            //Assign new value of WrappedValue to UserDefaults key
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// Keeps all saved preferences
struct Saved {
    
    static var data = Saved()
    
    @Storage(key: "First Run", defaultValue: true) static var firstRun: Bool
    
    @Storage(key: "Daily Update", defaultValue: Date.now) static var dailyUpdate: Date
    @Storage(key: "Weekly Update", defaultValue: Date.now) static var weeklyUpdate: Date
    @Storage(key: "Monthly Update", defaultValue: Date.now) static var monthlyUpdate: Date
    
    func retrieveImage(from string: String) -> UIImage? {
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(string)
        
        // If a value exists, return it as Data, else return nil
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        // Convert it from Data to whatever type it is
        return UIImage(data: data)
    }
    
    func save(image: UIImage, uniqueName: String) {
        
        guard let data = image.pngData() else { return }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(uniqueName)
        
        do {
            // Write to Disk
            try data.write(to: url)
            
        } catch {
            print("Unable to Write Data to Disk (\(error))")
        }
    }
}



//Caching
@propertyWrapper
struct Cache<T: Codable> {
    // The key is the key used for FileManager
    let key: String
    // A default value is needed so that the user doesn't retrieve a nil value
    let defaultValue: T
    
    // Variable must be initialized with a key
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    // WrappedValue is required for a propertyWrapper - this is the value that is going to be wrapped. In this case, it's generic (codable)
    var wrappedValue: T {
        get {
            
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(key)
            
            // If a value exists, return it as Data, else return nil
            guard let data = try? Data(contentsOf: url) else {
                return defaultValue
            }
            
            // Convert it from Data to whatever type it is
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(key)
            
            do {
                // Write to Disk
                try data.write(to: url)
                
            } catch {
                print("Unable to Write Data to Disk (\(error))")
            }
        }
    }
}

//Cached.teamDictionary

// Keeps all saved preferences

enum DictionaryType {
    case favoriteLeagues
    //case favoriteMatchesByDate
    //case favoriteMatchDictionary
    case favoriteTeams
    
    case injuriesByTeam
    
    case leagueDictionary

    case matchesByDate
    case matchesByLeague
    case matchesByTeam
    case matchDictionary
    
    case playersByTeam
    case playerDictionary
    
    case teamDictionary

    case tranfersByTeam
    case transferDictionary
}

actor Cached {
    
    static var data = Cached()
    
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    //@Cache(key: "Leagues", defaultValue: []) static var favoriteLeagueIds: [Int]
    @Cache(key: "*Favorite Leagues", defaultValue: [:]) var favoriteLeagues: LeagueDictionary
    // Save an array of "FavoriteTeam" items with the key "Teams" by initializing an empty array as a default value
    //@Cache(key: "Teams", defaultValue: []) static var favoriteTeamIds: [Int]
    @Cache(key: "*Favorite Teams", defaultValue: [:]) var favoriteTeams: TeamDictionary
    
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    //@Cache(key: "Matches By Day", defaultValue: [:]) static var matchesByDay: [DateString: Dictionary<Int,LeagueObject>]
    //@Cache(key: "Favorite Team Matches By Day", defaultValue: [:]) static var favoriteTeamMatchesByDay: [DateString:LeagueObject]
    
    // References
    //@Cache(key: "*Favorite Matches By Date", defaultValue: [:]) var favoriteMatchesByDateSet: MatchesByDateDictionary
    //@Cache(key: "*Favorite Match Dictionary", defaultValue: [:]) var favoriteMatchesDictionary: [MatchUniqueID:MatchObject]
    
    @Cache(key: "*Matches By Date", defaultValue: [:]) var matchesByDateSet: MatchesByDateDictionary
    @Cache(key: "*Matches By League", defaultValue: [:]) var matchesByLeagueSet: MatchesByLeagueDictionary
   
    @Cache(key: "*Matches By Team", defaultValue: [:]) var matchesByTeam: MatchesByTeamDictionary
    @Cache(key: "*Injuries By Team", defaultValue: [:]) var injuriesByTeam: InjuriesByTeamDictionary
    @Cache(key: "*Transfers By Team", defaultValue: [:]) var transfersByTeam: TransfersByTeamDictionary
    @Cache(key: "*Players By Team", defaultValue: [:]) var playersByTeam: PlayersByTeamDictionary
    
    // Dictionaries

    @Cache(key: "*Injury Dictionary", defaultValue: [:]) var injuryDictionary: InjuryDictionary
    @Cache(key: "*League Dictionary", defaultValue: [:]) var leagueDictionary: LeagueDictionary
    @Cache(key: "*Match Dictionary", defaultValue: [:]) var matchesDictionary: MatchesDictionary
    @Cache(key: "*Player Dictionary", defaultValue: [:]) var playerDictionary: PlayerDictionary
    @Cache(key: "*Team Dictionary", defaultValue: [:]) var teamDictionary: TeamDictionary
    @Cache(key: "*Transfer Dictionary", defaultValue: [:]) var transferDictionary: TransferDictionary
    
    func clearData() {
        self.favoriteLeagues = [:]
        self.favoriteTeams = [:]
        
        //self.favoriteMatchesByDateSet = [:]
        //self.favoriteMatchesDictionary = [:]
        
        self.matchesByDateSet = [:]
        self.matchesByLeagueSet = [:]
        self.matchesByTeam = [:]
        
        self.injuriesByTeam = [:]
        self.transfersByTeam = [:]

        self.teamDictionary = [:]
        self.leagueDictionary = [:]
        self.matchesDictionary = [:]
        self.injuryDictionary = [:]
        self.playerDictionary = [:]
        self.transferDictionary = [:]
    }
    
    func setFavoriteLeagues(with id: LeagueID, to value: LeagueObject?) {
        self.favoriteLeagues[id] = value
    }
    
    func setFavoriteTeams(with id: TeamID, to value: TeamObject?) {
        self.favoriteTeams[id] = value
    }
    
    func setTeamDictionary(with id: TeamID, to value: TeamObject) {
        self.teamDictionary[id] = value
    }
    
    //
    
    /*
    func getFavoriteMatchesDictionary() -> [MatchUniqueID:MatchObject] {
        return self.favoriteMatchesDictionary
    }
     */
    
    func getMatchesDictionary() -> [MatchUniqueID:MatchObject] {
        return self.matchesDictionary
    }
    
    func getMatchesByTeamDictionary() -> MatchesByTeamDictionary {
        return self.matchesByTeam
    }
    
    func getFavoriteLeagues() -> [LeagueID:LeagueObject] {
        return self.favoriteLeagues
    }
    
    func getFavoriteTeams() -> [TeamID:TeamObject] {
        return self.favoriteTeams
    }
    
    //
    
    func favoriteTeamsRemoveValue(forKey key: TeamID) {
        favoriteTeams.removeValue(forKey: key)
        
    }
    
    //
    
    func injuryDictionary(_ id: InjuryID) -> InjuryObject? {
        return self.injuryDictionary[id]
    }
    
    func leagueDictionary(_ id: LeagueID) -> LeagueObject? {
        return self.leagueDictionary[id]
    }
    
    func matchesDictionary(_ id: MatchUniqueID) -> MatchObject? {
        return self.matchesDictionary[id]
    }
    
    func playerDictionary(_ id: PlayerID) -> PlayerObject? {
        return self.playerDictionary[id]
    }
    
    func teamDictionary(_ id: TeamID) -> TeamObject? {
        return self.teamDictionary[id]
    }
    
    func transferDictionary(_ id: TransferID) -> TransferObject? {
        return self.transferDictionary[id]
    }
    
    func matchesByDateSet(_ id: DateString) -> Set<MatchUniqueID>? {
        return self.matchesByDateSet[id]
    }
    
    //
    
    func leagueDictionaryAddIfNoneExists(_ league: LeagueObject, key: LeagueID) {
        self.leagueDictionary.addIfNoneExists(league, key: key)
    }
    
    func playerDictionaryAddIfNoneExists(_ player: PlayerObject, key: PlayerID) {
        self.playerDictionary.addIfNoneExists(player, key: key)
    }
    
    func teamDictionaryAddIfNoneExists(_ team: TeamObject, key: TeamID) {
        self.teamDictionary.addIfNoneExists(team, key: key)
    }
    
    //
    
    /*
    func favoriteMatchesByDateSetIntegrate(_ favoriteMatchesByDateSet: [DateString: Set<MatchUniqueID>]) {
        self.favoriteMatchesByDateSet.integrateSet(favoriteMatchesByDateSet)
    }
    
    func favoriteMatchesDictionaryIntegrate(_ favoriteMatchesDictionary: [MatchUniqueID:MatchObject], replaceExistingValue: Bool) {
        self.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: replaceExistingValue)
    }
     */
    
    func injuriesByTeamIntegrate(_ injuriesByTeam: [TeamID:Set<InjuryID>]) {
        self.injuriesByTeam.integrateSet(injuriesByTeam)
    }
    
    func injuryDictionaryIntegrate(_ injuryDictionary: [InjuryID:InjuryObject], replaceExistingValue: Bool) {
        self.injuryDictionary.integrate(injuryDictionary, replaceExistingValue: replaceExistingValue)
    }
    
    func leagueDictionaryIntegrate(_ leagueDictionary: [LeagueID:LeagueObject], replaceExistingValue: Bool) {
        self.leagueDictionary.integrate(leagueDictionary, replaceExistingValue: replaceExistingValue)
    }
    
    func matchesByLeagueSetIntegrate(_ matchesByLeagueSet: [LeagueID: Set<MatchUniqueID>]) {
        self.matchesByLeagueSet.integrateSet(matchesByLeagueSet)
    }
    
    
    func matchesByDateSetIntegrate(_ matchesByDateSet: [DateString: Set<MatchUniqueID>]) {
        self.matchesByDateSet.integrateSet(matchesByDateSet)
    }
    
    
    func matchesByTeamIntegrate(_ matchesByTeam: [TeamID:Set<MatchUniqueID>]) {
        self.matchesByTeam.integrateSet(matchesByTeam)
    }
    
    func matchesDictionaryIntegrate(_ matchesDictionary: [MatchUniqueID:MatchObject], replaceExistingValue: Bool) {
        self.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: replaceExistingValue)
    }
    
    func playersByTeamIntegrate(_ playersByTeam: [TeamID:Set<PlayerID>]) {
        self.playersByTeam.integrateSet(playersByTeam)
    }
    
    func playerDictionaryIntegrate(_ playerDictionary: [PlayerID:PlayerObject], replaceExistingValue: Bool) {
        self.playerDictionary.integrate(playerDictionary, replaceExistingValue: replaceExistingValue)
    }
    
    func teamDictionaryIntegrate(_ teamDictionary: [TeamID:TeamObject], replaceExistingValue: Bool) {
        self.teamDictionary.integrate(teamDictionary, replaceExistingValue: replaceExistingValue)
    }
    
    func transfersByTeamIntegrate(_ transfersByTeam: [TeamID:Set<TransferID>]) {
        self.transfersByTeam.integrateSet(transfersByTeam)
    }
    
    func transferDictionaryIntegrate(_ transferDictionary: [TransferID:TransferObject], replaceExistingValue: Bool) {
        self.transferDictionary.integrate(transferDictionary, replaceExistingValue: replaceExistingValue)
    }
    
    func retrieveImage(from string: String) -> UIImage? {
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(string)
        
        // If a value exists, return it as Data, else return nil
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        // Convert it from Data to whatever type it is
        return UIImage(data: data)
    }
    
    func save(image: UIImage, uniqueName: String) {
        
        guard let data = image.pngData() else { return }
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(uniqueName)
        
        do {
            // Write to Disk
            try data.write(to: url)
            
        } catch {
            print("Unable to Write Data to Disk (\(error))")
        }
    }
}

/*
func callTeamDictionary(_ key: TeamID, _ value: TeamObject, source: String) {
    print("---")
    print("\(source) - add \(value) to teamDictionary with key \(key)")
    print("\(source) - \(value) -  Value found in dictionary before adding - \(Cached.teamDictionary[key])")
    print("\(source) - \(value) -  Count of items in dictionary before adding \(Cached.teamDictionary.count)")
    Cached.teamDictionary.addIfNoneExists(value, key: key)
    print("\(source) - \(value) -  Value found in dictionary after adding - \(Cached.teamDictionary[key])")
    print("\(source) - \(value) -  Count of items in dictionary after adding \(Cached.teamDictionary.count)")
    print()
}
*/

/*
actor CachedMatchesActor {
    
    static var helper = CachedMatchesActor()
    
    @Cache(key: "*Match Dictionary", defaultValue: [:]) var matchesDictionary: MatchesDictionary
    
    func getMatchesDictionary() -> [MatchUniqueID:MatchObject] {
        return self.matchesDictionary
    }
    
    func matchesDictionaryIntegrate(_ matchesDictionary: [MatchUniqueID:MatchObject], replaceExistingValue: Bool) {
        self.matchesDictionary.integrate(matchesDictionary, replaceExistingValue: replaceExistingValue)
    }
}
 */

class CachedFavorites {
    
    static var helper = CachedFavorites()
    
    var favoriteLeagues: LeagueDictionary = [:]
    var favoriteTeams: TeamDictionary = [:]
    
    init() {
        Task.init {
            favoriteLeagues = await Cached.data.favoriteLeagues
            favoriteTeams = await Cached.data.favoriteTeams
        }
    }
    
    func update() async {
        favoriteLeagues = await Cached.data.favoriteLeagues
        favoriteTeams = await Cached.data.favoriteTeams
    }
}

class CachedMatches {
    
    static var helper = CachedMatches()
    
    var matchesDictionary: MatchesDictionary = [:]
    
    var matchesByDateSet: MatchesByDateDictionary = [:]
    var matchesByLeagueSet: MatchesByLeagueDictionary = [:]
   
    var matchesByTeam: MatchesByTeamDictionary = [:]
    var injuriesByTeam: InjuriesByTeamDictionary = [:]
    var transfersByTeam: TransfersByTeamDictionary = [:]
    var playersByTeam: PlayersByTeamDictionary = [:]
    
    init() {
        Task.init {
            matchesDictionary = await Cached.data.matchesDictionary
            matchesByDateSet = await Cached.data.matchesByDateSet
            matchesByLeagueSet = await Cached.data.matchesByLeagueSet
           
            matchesByTeam = await Cached.data.matchesByTeam
            injuriesByTeam = await Cached.data.injuriesByTeam
            transfersByTeam = await Cached.data.transfersByTeam
            playersByTeam = await Cached.data.playersByTeam
        }
    }
    
    func update() async {
        matchesDictionary = await Cached.data.matchesDictionary
        matchesByDateSet = await Cached.data.matchesByDateSet
        matchesByLeagueSet = await Cached.data.matchesByLeagueSet
       
        matchesByTeam = await Cached.data.matchesByTeam
        injuriesByTeam = await Cached.data.injuriesByTeam
        transfersByTeam = await Cached.data.transfersByTeam
        playersByTeam = await Cached.data.playersByTeam
    }
}

class CachedTeams {
    static var helper = CachedTeams()
    
    var teamDictionary: TeamDictionary = [:]
    
    init() {
        Task.init {
            teamDictionary = await Cached.data.teamDictionary
        }
    }
    
    func update() async {
            teamDictionary = await Cached.data.teamDictionary
    }
}

class CachedLeagues {
    static var helper = CachedLeagues()
    
    var leagueDictionary: LeagueDictionary = [:]
    
    init() {
        Task.init {
            leagueDictionary = await Cached.data.leagueDictionary
        }
    }
    
    func update() async {
            leagueDictionary = await Cached.data.leagueDictionary
    }
}
