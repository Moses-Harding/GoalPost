//
//  UserSettings.swift
//  GoalPost
//
//  Created by Moses Harding on 5/4/22.
//

// More on property wrappers - https://www.swiftbysundell.com/articles/property-wrappers-in-swift/

import Foundation

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
    // Save an array of "FavoriteLeague" items with the key "Leagues" by initializing an empty array as a default value
    @Storage(key: "Leagues", defaultValue: [FavoriteLeague]()) static var leagues: [FavoriteLeague]
    // Save an array of "FavoriteTeam" items with the key "Teams" by initializing an empty array as a default value
    @Storage(key: "Teams", defaultValue: [FavoriteTeam]()) static var teams: [FavoriteTeam]
}

// MARK: Saved data structures
struct FavoriteLeague: Codable {
    var leagueName: String
    var leagueCountry: String?
    var leagueID: Int
}

struct FavoriteTeam: Codable {
    var teamName: String
    var teamLeague: String
    var teamID: Int
}
