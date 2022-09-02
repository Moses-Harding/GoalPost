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
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    func dayOfWeekFormat() -> String {
        return self.formatted(Date.FormatStyle().weekday(.wide).month(.defaultDigits).day(.defaultDigits).year(.twoDigits))
    }
}
