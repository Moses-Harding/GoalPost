//
//  Dictionary.swift
//  GoalPost
//
//  Created by Moses Harding on 5/29/22.
//

import Foundation

extension Dictionary {
    
    mutating func addIfNoneExists(_ element: Value, key: Key) {
        if self[key] == nil {
            self[key] = element
        }
    }
    
    mutating func add<T>(_ element: T, toSetWithKey key: Key) where Value == Set<T> {
        if self[key]  == nil {
            self[key] = Set<T>(arrayLiteral: element)
        } else {
            self[key]?.insert(element)
        }
    }
    
    mutating func add<T>(_ set: Set<T>, toSetWithKey key: Key) where Value == Set<T> {
        if self[key]  == nil {
            self[key] = set
        } else {
            self[key] = self[key]?.union(set)
        }
    }
    
    mutating func integrate(_ dictionary: [Key:Value], replaceExistingValue: Bool) {
        for (key, value) in dictionary {
            if self[key] == nil || replaceExistingValue {
                self[key] = value
            }
        }
    }
    
    mutating func integrate<T>(dictionaryWithSet dictionary: [Key:Set<T>]) where Value == Set<T> {
        for (key, value) in dictionary {
            self.add(value, toSetWithKey: key)
        }
    }
}
