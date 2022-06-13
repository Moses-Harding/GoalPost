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
struct Cached {
    
    static var data = Cached()
    
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    //@Cache(key: "Leagues", defaultValue: []) static var favoriteLeagueIds: [Int]
    @Cache(key: "*Favorite Leagues", defaultValue: [:]) static var favoriteLeagues: [LeagueID:LeagueObject]
    // Save an array of "FavoriteTeam" items with the key "Teams" by initializing an empty array as a default value
    //@Cache(key: "Teams", defaultValue: []) static var favoriteTeamIds: [Int]
    @Cache(key: "*Favorite Teams", defaultValue: [:]) static var favoriteTeams: [TeamID:TeamObject]
    
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    //@Cache(key: "Matches By Day", defaultValue: [:]) static var matchesByDay: [DateString: Dictionary<Int,LeagueObject>]
    //@Cache(key: "Favorite Team Matches By Day", defaultValue: [:]) static var favoriteTeamMatchesByDay: [DateString:LeagueObject]
    
    // References
    @Cache(key: "*Favorite Matches By Date", defaultValue: [:]) static var favoriteMatchesByDateSet: [DateString: Set<MatchUniqueID>]
    @Cache(key: "*Favorite Match Dictionary", defaultValue: [:]) static var favoriteMatchesDictionary: [MatchUniqueID:MatchObject]
    
    @Cache(key: "*Matches By Date", defaultValue: [:]) static var matchesByDateSet: [DateString: Set<MatchUniqueID>]
    @Cache(key: "*Matches By League", defaultValue: [:]) static var matchesByLeagueSet: [LeagueID: Set<MatchUniqueID>]
    @Cache(key: "*Matches By Team", defaultValue: [:]) static var matchesByTeam: [TeamID:Set<MatchUniqueID>]
    
    @Cache(key: "*Injuries By Team", defaultValue: [:]) static var injuriesByTeam: [TeamID:Set<InjuryID>]
    @Cache(key: "*Transfers By Team", defaultValue: [:]) static var transfersByTeam: [TeamID:Set<TransferID>]
    
    // Dictionaries
    @Cache(key: "*Team Dictionary", defaultValue: [:]) static var teamDictionary: [TeamID:TeamObject]
    @Cache(key: "*League Dictionary", defaultValue: [:]) static var leagueDictionary: [LeagueID:LeagueObject]
    @Cache(key: "*Player Dictionary", defaultValue: [:]) static var playerDictionary: [PlayerID:PlayerObject]
    @Cache(key: "*Injury Dictionary", defaultValue: [:]) static var injuryDictionary: [InjuryID:InjuryObject]
    @Cache(key: "*Match Dictionary", defaultValue: [:]) static var matchesDictionary: [MatchUniqueID:MatchObject]
    @Cache(key: "*Transfer Dictionary", defaultValue: [:]) static var transferDictionary: [TransferID:TransferObject]
    
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
