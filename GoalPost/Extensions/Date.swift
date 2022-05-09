//
//  Date.swift
//  GoalPost
//
//  Created by Moses Harding on 5/8/22.
//

import Foundation

extension Date {
    
    var asKey: String {
        return self.formatted(date: .numeric, time: .omitted)
    }
}
