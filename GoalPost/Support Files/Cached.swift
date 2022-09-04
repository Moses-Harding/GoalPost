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

enum CachedDictionaryType: String {
    case favoriteLeaguesDictionary = "*Favorite Leagues"
    case favoriteTeamsDictionary = "*Favorite Teams"
    case matchesByDateDictionary = "*Matches By Date"
    case matchesByLeagueDictionary = "*Matches By League"
    case matchesByTeamDictionary = "*Matches By Team"
    case injuriesByTeamDictionary = "*Injuries By Team"
    case transfersByTeamDictionary = "*Transfers By Team"
    case playersByTeamDictionary = "*Players By Team"
    case injuryDictionary = "*Injury Dictionary"
    case leagueDictionary = "*League Dictionary"
    case matchesDictionary = "*Match Dictionary"
    case playerDictionary = "*Player Dictionary"
    case teamDictionary = "*Team Dictionary"
    case transferDictionary = "*Transfer Dictionary"
}

enum CacheDictionary: String {
    case favoriteTeamsDictionary
    case favoriteLeaguesDictionary
    case injuryDictionary
    case leagueDictionary
    case matchesDictionary
    case playerDictionary
    case teamDictionary
    case transferDictionary
}

enum CacheSetDictionary: String {
    case matchesByDateDictionary
    case matchesByLeagueDictionary
    case matchesByTeamDictionary
    case injuriesByTeamDictionary
    case transfersByTeamDictionary
    case playersByTeamDictionary
}

actor Cached {
    
    static var data = Cached()
    
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    //@Cache(key: CachedDictionaryType.favoriteLeagueIds.rawValue, defaultValue: [:]) var favoriteLeagueIds: [Int]
    @Cache(key: CachedDictionaryType.favoriteLeaguesDictionary.rawValue, defaultValue: [:]) var favoriteLeaguesDictionary: LeagueDictionary
    // Save an array of "FavoriteTeam" items with the key "Teams" by initializing an empty array as a default value
    //@Cache(key: CachedDictionaryType.favoriteTeamIds.rawValue, defaultValue: [:]) var favoriteTeamIds: [Int]
    @Cache(key: CachedDictionaryType.favoriteTeamsDictionary.rawValue, defaultValue: [:]) var favoriteTeamsDictionary: TeamDictionary
    
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    //@Cache(key: CachedDictionaryType.matchesByDay: [DateString.rawValue, defaultValue: [:]) var matchesByDay: [DateString: Dictionary<Int,LeagueObject>]
    //@Cache(key: CachedDictionaryType.favoriteTeamMatchesByDay.rawValue, defaultValue: [:]) var favoriteTeamMatchesByDay: [DateString:LeagueObject]
    
    // References
    //@Cache(key: CachedDictionaryType.favoriteMatchesByDateSet.rawValue, defaultValue: [:]) var favoriteMatchesByDateSet: MatchesByDateDictionary
    //@Cache(key: CachedDictionaryType.favoriteMatchesDictionary.rawValue, defaultValue: [:]) var favoriteMatchesDictionary: [MatchUniqueID:MatchObject]
    
    @Cache(key: CachedDictionaryType.matchesByDateDictionary.rawValue, defaultValue: [:]) var matchesByDateDictionary: MatchesByDateDictionary
    @Cache(key: CachedDictionaryType.matchesByLeagueDictionary.rawValue, defaultValue: [:]) var matchesByLeagueDictionary: MatchesByLeagueDictionary
   
    @Cache(key: CachedDictionaryType.matchesByTeamDictionary.rawValue, defaultValue: [:]) var matchesByTeamDictionary: MatchesByTeamDictionary
    @Cache(key: CachedDictionaryType.injuriesByTeamDictionary.rawValue, defaultValue: [:]) var injuriesByTeamDictionary: InjuriesByTeamDictionary
    @Cache(key: CachedDictionaryType.transfersByTeamDictionary.rawValue, defaultValue: [:]) var transfersByTeamDictionary: TransfersByTeamDictionary
    @Cache(key: CachedDictionaryType.playersByTeamDictionary.rawValue, defaultValue: [:]) var playersByTeamDictionary: PlayersByTeamDictionary
    
    // Dictionaries

    @Cache(key: CachedDictionaryType.injuryDictionary.rawValue, defaultValue: [:]) var injuryDictionary: InjuryDictionary
    @Cache(key: CachedDictionaryType.leagueDictionary.rawValue, defaultValue: [:]) var leagueDictionary: LeagueDictionary
    @Cache(key: CachedDictionaryType.matchesDictionary.rawValue, defaultValue: [:]) var matchesDictionary: MatchesDictionary
    @Cache(key: CachedDictionaryType.playerDictionary.rawValue, defaultValue: [:]) var playerDictionary: PlayerDictionary
    @Cache(key: CachedDictionaryType.teamDictionary.rawValue, defaultValue: [:]) var teamDictionary: TeamDictionary
    @Cache(key: CachedDictionaryType.transferDictionary.rawValue, defaultValue: [:]) var transferDictionary: TransferDictionary
    
    func clearData() {
        self.favoriteLeaguesDictionary = [:]
        self.favoriteTeamsDictionary = [:]
    
        self.matchesByDateDictionary = [:]
        self.matchesByLeagueDictionary = [:]
        self.matchesByTeamDictionary = [:]
        
        self.injuriesByTeamDictionary = [:]
        self.transfersByTeamDictionary = [:]

        self.teamDictionary = [:]
        self.leagueDictionary = [:]
        self.matchesDictionary = [:]
        self.injuryDictionary = [:]
        self.playerDictionary = [:]
        self.transferDictionary = [:]
    }
    
    func set(_ type: CacheDictionary, with key: Any, to object: Any, calledBy: String) {
        
        print("Cached.data - Set - Called By \(calledBy) - \(Date.now.timeStamp)")
        
        switch type {
            
        case .injuryDictionary:
            guard let object = object as? InjuryObject, let key = key as? InjuryID else { fatalError() }
            self.injuryDictionary[key] = object
            print("WARNING: Cached - addIfNoneExists - QuickCache not implemented for \(type.rawValue)")
        case .leagueDictionary:
            guard let object = object as? LeagueObject, let key = key as? LeagueID else { fatalError() }
            self.leagueDictionary[key] = object
            QuickCache.helper.set(.leagueDictionary, dictionary: leagueDictionary)
        case .matchesDictionary:
            guard let object = object as? MatchObject, let key = key as? MatchUniqueID else { fatalError() }
            self.matchesDictionary[key] = object
            QuickCache.helper.set(.matchesDictionary, dictionary: matchesDictionary)
        case .playerDictionary:
            guard let object = object as? PlayerObject, let key = key as? PlayerID else { fatalError() }
            self.playerDictionary[key] = object
            print("WARNING: Cached - addIfNoneExists - QuickCache not implemented for \(type.rawValue)")
        case .teamDictionary:
            guard let object = object as? TeamObject, let key = key as? TeamID else { fatalError() }
            self.teamDictionary[key] = object
            QuickCache.helper.set(.teamDictionary, dictionary: teamDictionary)
        case .transferDictionary:
            guard let object = object as? TransferObject, let key = key as? TransferID else { fatalError() }
            self.transferDictionary[key] = object
            print("WARNING: Cached - addIfNoneExists - QuickCache not implemented for \(type.rawValue)")
        case .favoriteTeamsDictionary:
            guard let object = object as? TeamObject, let key = key as? TeamID else { fatalError() }
            self.favoriteTeamsDictionary[key] = object
            QuickCache.helper.set(.favoriteTeamsDictionary, dictionary: favoriteTeamsDictionary)
        case .favoriteLeaguesDictionary:
            guard let object = object as? LeagueObject, let key = key as? LeagueID else { fatalError() }
            self.favoriteLeaguesDictionary[key] = object
            QuickCache.helper.set(.favoriteLeaguesDictionary, dictionary: favoriteLeaguesDictionary)
        }
    }

    
    //
    
    func favoriteTeamsRemoveValue(forKey key: TeamID) {
        //print("Cached.data - Favorite Teams Remove Value - Called By \(calledBy) - \(Date.now.timeStamp)")
        favoriteTeamsDictionary.removeValue(forKey: key)
        QuickCache.helper.set(.favoriteTeamsDictionary, dictionary: self.favoriteTeamsDictionary)
    }
    
    func favoriteLeaguesRemoveValue(forKey key: LeagueID) {
        //print("Cached.data - Favorite Leagues Remove Value - Called By \(calledBy) - \(Date.now.timeStamp)")
        favoriteLeaguesDictionary.removeValue(forKey: key)
        QuickCache.helper.set(.favoriteLeaguesDictionary, dictionary: self.favoriteLeaguesDictionary)
    }
    
    //
    
    func playerDictionary(_ id: PlayerID) -> PlayerObject? {
        //print("Cached.data - PlayerDictionary - Called By \(calledBy) - \(Date.now.timeStamp)")
        return self.playerDictionary[id]
    }
    
    func injuryDictionary(_ id: InjuryID) -> InjuryObject? {
        //print("Cached.data - Injury Dictionary - Called By \(calledBy) - \(Date.now.timeStamp)")
        return self.injuryDictionary[id]
    }
    
    func transferDictionary(_ id: TransferID) -> TransferObject? {
        //print("Cached.data - TransferDictionary - Called By \(calledBy) - \(Date.now.timeStamp)")
        return self.transferDictionary[id]
    }
    
    
    func addIfNoneExists(_ type: CacheDictionary, _ object: Any, key: Any, calledBy: String) {
        
        //print("Cached.data - AddIfNoneExists - Called By \(calledBy) - \(Date.now.timeStamp)")
        
        switch type {
            
        case .injuryDictionary:
            guard let object = object as? InjuryObject, let key = key as? InjuryID else { fatalError() }
            self.injuryDictionary.addIfNoneExists(object, key: key)
            print("WARNING: Cached - addIfNoneExists - QuickCache not implemented for \(type.rawValue)")
        case .leagueDictionary:
            guard let object = object as? LeagueObject, let key = key as? LeagueID else { fatalError() }
            self.leagueDictionary.addIfNoneExists(object, key: key)
            QuickCache.helper.set(.leagueDictionary, dictionary: leagueDictionary)
        case .matchesDictionary:
            guard let object = object as? MatchObject, let key = key as? MatchUniqueID else { fatalError() }
            self.matchesDictionary.addIfNoneExists(object, key: key)
            QuickCache.helper.set(.matchesDictionary, dictionary: matchesDictionary)
        case .playerDictionary:
            guard let object = object as? PlayerObject, let key = key as? PlayerID else { fatalError() }
            self.playerDictionary.addIfNoneExists(object, key: key)
            print("WARNING: Cached - addIfNoneExists - QuickCache not implemented for \(type.rawValue)")
        case .teamDictionary:
            guard let object = object as? TeamObject, let key = key as? TeamID else { fatalError() }
            self.teamDictionary.addIfNoneExists(object, key: key)
            QuickCache.helper.set(.teamDictionary, dictionary: teamDictionary)
        case .transferDictionary:
            guard let object = object as? TransferObject, let key = key as? TransferID else { fatalError() }
            self.transferDictionary.addIfNoneExists(object, key: key)
            print("WARNING: Cached - addIfNoneExists - QuickCache not implemented for \(type.rawValue)")
        case .favoriteTeamsDictionary:
            guard let object = object as? TeamObject, let key = key as? TeamID else { fatalError() }
            self.favoriteTeamsDictionary.addIfNoneExists(object, key: key)
            QuickCache.helper.set(.favoriteTeamsDictionary, dictionary: teamDictionary)
        case .favoriteLeaguesDictionary:
            guard let object = object as? LeagueObject, let key = key as? LeagueID else { fatalError() }
            self.favoriteLeaguesDictionary.addIfNoneExists(object, key: key)
            QuickCache.helper.set(.favoriteLeaguesDictionary, dictionary: leagueDictionary)
        }
    }

    
    func integrateSet<T, U>(type: CacheSetDictionary, dictionary: Dictionary<T, Set<U>>, calledBy: String) {
        
        print("Cached.data - IntegrateSet - Called By \(calledBy) - \(Date.now.timeStamp)")
        
        switch type {
        case .matchesByDateDictionary:
            guard let dictionary = dictionary as? MatchesByDateDictionary else { fatalError() }
            self.matchesByDateDictionary.integrateSet(dictionary)
            QuickCache.helper.set(.matchesByDateDictionary, dictionary: matchesByDateDictionary)
        case .matchesByLeagueDictionary:
            guard let dictionary = dictionary as? MatchesByLeagueDictionary else { fatalError() }
            self.matchesByLeagueDictionary.integrateSet(dictionary)
            QuickCache.helper.set(.matchesByLeagueDictionary, dictionary: matchesByLeagueDictionary)
        case .matchesByTeamDictionary:
            guard let dictionary = dictionary as? MatchesByTeamDictionary else { fatalError() }
            self.matchesByTeamDictionary.integrateSet(dictionary)
            QuickCache.helper.set(.matchesByTeamDictionary, dictionary: matchesByTeamDictionary)
        case .injuriesByTeamDictionary:
            guard let dictionary = dictionary as? InjuriesByTeamDictionary else { fatalError() }
            self.injuriesByTeamDictionary.integrateSet(dictionary)
            print("WARNING: Cached - integrateSet - QuickCache not implemented for \(type.rawValue)")
        case .transfersByTeamDictionary:
            guard let dictionary = dictionary as? TransfersByTeamDictionary else { fatalError() }
            self.transfersByTeamDictionary.integrateSet(dictionary)
            print("WARNING: Cached - integrateSet - QuickCache not implemented for \(type.rawValue)")
        case .playersByTeamDictionary:
            guard let dictionary = dictionary as? PlayersByTeamDictionary else { fatalError() }
            self.playersByTeamDictionary.integrateSet(dictionary)
            print("WARNING: Cached - integrateSet - QuickCache not implemented for \(type.rawValue)")
        }
    }
    
    func integrate<T, U>(type: CacheDictionary, dictionary: Dictionary<T, U>, replaceExistingValue replace: Bool, calledBy: String) {
        
        print("Cached.data - Integrate - Called By \(calledBy) - \(Date.now.timeStamp)")
        
        switch type {
        case .injuryDictionary:
            guard let dictionary = dictionary as? InjuryDictionary else { fatalError() }
            injuryDictionary.integrate(dictionary, replaceExistingValue: replace)
            print("WARNING: Cached - integrate - QuickCache not implemented for \(type.rawValue)")
        case .leagueDictionary:
            guard let dictionary = dictionary as? LeagueDictionary else { fatalError() }
            leagueDictionary.integrate(dictionary, replaceExistingValue: replace)
            QuickCache.helper.set(.leagueDictionary, dictionary: leagueDictionary)
        case .matchesDictionary:
            guard let dictionary = dictionary as? MatchesDictionary else { fatalError() }
            matchesDictionary.integrate(dictionary, replaceExistingValue: replace)
            QuickCache.helper.set(.matchesDictionary, dictionary: matchesDictionary)
        case .playerDictionary:
            guard let dictionary = dictionary as? PlayerDictionary else { fatalError() }
            playerDictionary.integrate(dictionary, replaceExistingValue: replace)
            print("WARNING: Cached - integrate - QuickCache not implemented for \(type.rawValue)")
        case .teamDictionary:
            guard let dictionary = dictionary as? TeamDictionary else { fatalError() }
            teamDictionary.integrate(dictionary, replaceExistingValue: replace)
            QuickCache.helper.set(.teamDictionary, dictionary: teamDictionary)
        case .transferDictionary:
            guard let dictionary = dictionary as? TransferDictionary else { fatalError() }
            transferDictionary.integrate(dictionary, replaceExistingValue: replace)
            print("WARNING: Cached - integrate - QuickCache not implemented for \(type.rawValue)")
        case .favoriteTeamsDictionary:
            guard let dictionary = dictionary as? TeamDictionary else { fatalError() }
            favoriteTeamsDictionary.integrate(dictionary, replaceExistingValue: replace)
            QuickCache.helper.set(.favoriteTeamsDictionary, dictionary: teamDictionary)
        case .favoriteLeaguesDictionary:
            guard let dictionary = dictionary as? LeagueDictionary else { fatalError() }
            favoriteLeaguesDictionary.integrate(dictionary, replaceExistingValue: replace)
            QuickCache.helper.set(.favoriteLeaguesDictionary, dictionary: leagueDictionary)
        }
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
 QuickCache allows READ ONLY access to the cache. Upon initializing, data is retrieved directly from the cache. Later throughout usage, the "Cached" actor updates QuickCache. The only time QuickCache accesses the Cache directly is at initialization (to prevent data races).
 */
class QuickCache {
    
    static var helper = QuickCache()
    
    private(set) var matchesDictionary: MatchesDictionary = [:]
    private(set) var matchesByDateDictionary: MatchesByDateDictionary = [:]
    private(set) var matchesByLeagueDictionary: MatchesByLeagueDictionary = [:]
    private(set) var matchesByTeamDictionary: MatchesByTeamDictionary = [:]
    
    private(set) var teamDictionary: TeamDictionary = [:]
    
    private(set) var leagueDictionary: LeagueDictionary = [:]
    
    private(set) var favoriteLeaguesDictionary: LeagueDictionary = [:]
    private(set) var favoriteTeamsDictionary: TeamDictionary = [:]
    
    func getInitialData() {
        retrieveDataManually(key: CachedDictionaryType.matchesDictionary.rawValue, dictionary: &self.matchesDictionary)
        retrieveDataManually(key: CachedDictionaryType.matchesByDateDictionary.rawValue, dictionary: &self.matchesByDateDictionary)
        retrieveDataManually(key: CachedDictionaryType.matchesByLeagueDictionary.rawValue, dictionary: &self.matchesByLeagueDictionary)
        retrieveDataManually(key: CachedDictionaryType.matchesByTeamDictionary.rawValue, dictionary: &self.matchesByTeamDictionary)
        
        retrieveDataManually(key: CachedDictionaryType.teamDictionary.rawValue, dictionary: &self.teamDictionary)
        
        retrieveDataManually(key: CachedDictionaryType.leagueDictionary.rawValue, dictionary: &self.leagueDictionary)
        
        retrieveDataManually(key: CachedDictionaryType.favoriteLeaguesDictionary.rawValue, dictionary: &self.favoriteLeaguesDictionary)
        retrieveDataManually(key: CachedDictionaryType.favoriteTeamsDictionary.rawValue, dictionary: &self.favoriteTeamsDictionary)
    }
    
    func set<T,U>(_ type: CachedDictionaryType, dictionary: Dictionary<T, U>) {
        
        switch type {
        case .favoriteLeaguesDictionary:
            guard let dictionary = dictionary as? LeagueDictionary else { fatalError() }
            self.favoriteLeaguesDictionary = dictionary
        case .favoriteTeamsDictionary:
            guard let dictionary = dictionary as? TeamDictionary else { fatalError() }
            self.favoriteTeamsDictionary = dictionary
        case .injuriesByTeamDictionary:
            print("QuickCache - Set - Dictionary Not configured for \(type)")
        case .leagueDictionary:
            guard let dictionary = dictionary as? LeagueDictionary else { fatalError() }
            self.leagueDictionary = dictionary
        case .matchesByDateDictionary:
            guard let dictionary = dictionary as? MatchesByDateDictionary else { fatalError() }
            self.matchesByDateDictionary = dictionary
        case .matchesByLeagueDictionary:
            guard let dictionary = dictionary as? MatchesByLeagueDictionary else { fatalError() }
            self.matchesByLeagueDictionary = dictionary
        case .matchesByTeamDictionary:
            guard let dictionary = dictionary as? MatchesByTeamDictionary else { fatalError() }
            self.matchesByTeamDictionary = dictionary
        case .matchesDictionary:
            guard let dictionary = dictionary as? MatchesDictionary else { fatalError() }
            self.matchesDictionary = dictionary
        case .playersByTeamDictionary:
            print("QuickCache - Set - Dictionary Not configured for \(type)")
        case .playerDictionary:
            print("QuickCache - Set - Dictionary Not configured for \(type)")
        case .teamDictionary:
            guard let dictionary = dictionary as? TeamDictionary else { fatalError() }
            self.teamDictionary = dictionary
        case .transfersByTeamDictionary:
            print("QuickCache - Set - Dictionary Not configured for \(type)")
        case .transferDictionary:
            print("QuickCache - Set - Dictionary Not configured for \(type)")
        case .injuryDictionary:
            print("QuickCache - Set - Dictionary Not configured for \(type)")
        }
    }
    
    func retrieveDataManually<T: Decodable, U: Decodable>(key: String, dictionary: inout Dictionary<T, U>) {
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(key)
        
        guard let data =  try? Data(contentsOf: url) else {
            print("Cached - GetInitialData - Could not locate key '\(key)'")
            return
        }
        let type = type(of: dictionary)
        guard let value = try? JSONDecoder().decode(type.self, from: data) else {
            print("Cached - GetInitialData - Could not convert value to type '\(type)' for key '\(key)'")
            return
        }
        dictionary = value
    }
    
    func updateMatches() async {
        matchesDictionary = await Cached.data.matchesDictionary
        matchesByDateDictionary = await Cached.data.matchesByDateDictionary
        matchesByLeagueDictionary = await Cached.data.matchesByLeagueDictionary
        matchesByTeamDictionary = await Cached.data.matchesByTeamDictionary
    }
    
    func updateTeams() async {
        teamDictionary = await Cached.data.teamDictionary
    }
    
    func updateLeagues() async {
        leagueDictionary = await Cached.data.leagueDictionary
    }
    
    
    func updateFavorites() async {
        favoriteLeaguesDictionary = await Cached.data.favoriteLeaguesDictionary
        favoriteTeamsDictionary = await Cached.data.favoriteTeamsDictionary
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
}
