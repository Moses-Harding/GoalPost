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
    @Storage(key: "First Run", defaultValue: true) static var firstRun: Bool
    
    @Storage(key: "Daily Update", defaultValue: Date.now) static var dailyUpdate: Date
    @Storage(key: "Weekly Update", defaultValue: Date.now) static var weeklyUpdate: Date
    @Storage(key: "Monthly Update", defaultValue: Date.now) static var monthlyUpdate: Date
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
    case favoriteMatchesByDate
    case favoriteMatchDictionary
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
    @Cache(key: "*Favorite Matches By Date", defaultValue: [:]) var favoriteMatchesByDateSet: MatchesByDateDictionary
    @Cache(key: "*Favorite Match Dictionary", defaultValue: [:]) var favoriteMatchesDictionary: [MatchUniqueID:MatchObject]
    
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
        
        self.favoriteMatchesByDateSet = [:]
        self.favoriteMatchesDictionary = [:]
        
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
    
    func getFavoriteMatchesDictionary() -> [MatchUniqueID:MatchObject] {
        return self.favoriteMatchesDictionary
    }
    
    func getMatchesDictionary() -> [MatchUniqueID:MatchObject] {
        return self.matchesDictionary
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
    
    func favoriteMatchesByDateSetIntegrate(_ favoriteMatchesByDateSet: [DateString: Set<MatchUniqueID>]) {
        self.favoriteMatchesByDateSet.integrateSet(favoriteMatchesByDateSet)
    }
    
    func favoriteMatchesDictionaryIntegrate(_ favoriteMatchesDictionary: [MatchUniqueID:MatchObject], replaceExistingValue: Bool) {
        self.favoriteMatchesDictionary.integrate(favoriteMatchesDictionary, replaceExistingValue: replaceExistingValue)
    }
    
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

class CacheHandler {
    
    static var shared = CacheHandler()
    
    var favoriteLeagues: LeagueDictionary = [:]
    var favoriteTeams: TeamDictionary = [:]
    
    var favoriteMatchesByDateSet: MatchesByDateDictionary = [:]
    var favoriteMatchesDictionary: MatchesDictionary = [:]
    
    var matchesByDateSet: MatchesByDateDictionary = [:]
    var matchesByLeagueSet: MatchesByLeagueDictionary = [:]
   
    var injuriesByTeam: InjuriesByTeamDictionary = [:]
    var matchesByTeam: MatchesByTeamDictionary = [:]
    var playersByTeam: PlayersByTeamDictionary = [:]
    var transfersByTeam: TransfersByTeamDictionary = [:]

    var injuryDictionary: InjuryDictionary = [:]
    var leagueDictionary: LeagueDictionary = [:]
    var matchesDictionary: MatchesDictionary = [:]
    var playerDictionary: PlayerDictionary = [:]
    var teamDictionary: TeamDictionary = [:]
    var transferDictionary: TransferDictionary = [:]
    
    init() {
        //DispatchQueue.global().async {
            Task.init {
                self.favoriteLeagues = await Cached.data.favoriteLeagues
                self.favoriteTeams = await Cached.data.favoriteTeams
                
                self.favoriteMatchesByDateSet = await Cached.data.favoriteMatchesByDateSet
                self.favoriteMatchesDictionary = await Cached.data.favoriteMatchesDictionary
                
                self.matchesByDateSet = await Cached.data.matchesByDateSet
                self.matchesByLeagueSet = await Cached.data.matchesByLeagueSet
                
                self.matchesByTeam = await Cached.data.matchesByTeam
                self.injuriesByTeam = await Cached.data.injuriesByTeam
                self.transfersByTeam = await Cached.data.transfersByTeam
                self.playersByTeam = await Cached.data.playersByTeam
                
                self.teamDictionary = await Cached.data.teamDictionary
                self.leagueDictionary = await Cached.data.leagueDictionary
                self.playerDictionary = await Cached.data.playerDictionary
                self.injuryDictionary = await Cached.data.injuryDictionary
                self.matchesDictionary = await Cached.data.matchesDictionary
                self.transferDictionary = await Cached.data.transferDictionary
            }
        //}
    }
    
    func integrate<Key: Hashable, Value: Any>(_ dictionaryType: DictionaryType, _ dictionary:
                                              Dictionary<Key,Value>, replaceExistingValue: Bool) {
        
        switch dictionaryType {
        case .favoriteLeagues:
            //guard Key.self as! LeagueDictionary.Key.Type, Value.self as! LeagueDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            
            guard let dictionary = dictionary as? LeagueDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.favoriteLeagues.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .favoriteMatchesByDate:
            //guard Key.self is MatchesByDateDictionary.Key.Type, Value.self is MatchesByDateDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? MatchesByDateDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.favoriteMatchesByDateSet.integrateSet(dictionary)
                }
            }
        case .favoriteMatchDictionary:
            //guard Key.self is MatchesDictionary.Key.Type, Value.self is MatchesDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? MatchesDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.favoriteMatchesDictionary.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .favoriteTeams:
            //guard Key.self is TeamDictionary.Key.Type, Value.self is TeamDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? TeamDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.favoriteTeams.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .injuriesByTeam:
            //guard Key.self is InjuriesByTeamDictionary.Key.Type, Value.self is InjuriesByTeamDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? InjuriesByTeamDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.injuriesByTeam.integrateSet(dictionary)
                }
            }
        case .leagueDictionary:
            //guard Key.self is LeagueDictionary.Key.Type, Value.self is LeagueDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? LeagueDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.leagueDictionary.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .matchesByDate:
            //guard Key.self is MatchesByDateDictionary.Key.Type, Value.self is MatchesByDateDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? MatchesByDateDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.matchesByDateSet.integrateSet(dictionary)
                }
            }
        case .matchesByLeague:
            //guard Key.self is MatchesByLeagueDictionary.Key.Type, Value.self is MatchesByLeagueDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? MatchesByLeagueDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.matchesByLeagueSet.integrateSet(dictionary)
                }
            }
        case .matchesByTeam:
            //guard Key.self is MatchesByTeamDictionary.Key.Type, Value.self is MatchesByTeamDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? MatchesByTeamDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.matchesByTeam.integrateSet(dictionary)
                }
            }
        case .matchDictionary:
            //guard Key.self is MatchesDictionary.Key.Type, Value.self is MatchesDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? MatchesDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.matchesDictionary.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .playersByTeam:
            //guard Key.self is PlayersByTeamDictionary.Key.Type, Value.self is PlayersByTeamDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? PlayersByTeamDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.playersByTeam.integrateSet(dictionary)
                }
            }
        case .playerDictionary:
            //guard Key.self is PlayerDictionary.Key.Type, Value.self is PlayerDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? PlayerDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.playerDictionary.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .teamDictionary:
            //guard Key.self is TeamDictionary.Key.Type, Value.self is TeamDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? TeamDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.teamDictionary.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
        case .tranfersByTeam:
            //guard Key.self is TransfersByTeamDictionary.Key.Type, Value.self is TransfersByTeamDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? TransfersByTeamDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.transfersByTeam.integrateSet(dictionary)
                }
            }
        case .transferDictionary:
            //guard Key.self is TransferDictionary.Key.Type, Value.self is TransferDictionary.Value.Type else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            guard let dictionary = dictionary as? TransferDictionary else { fatalError("CacheHandler - Integrate - Incorrect dictionary type passed") }
            DispatchQueue.global().async {
                Task.init {
                    self.transferDictionary.integrate(dictionary, replaceExistingValue: replaceExistingValue)
                }
            }
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
