//
//  Date.swift
//  GoalPost
//
//  Created by Moses Harding on 5/8/22.
//

import Foundation

extension Date {
    
    public var removeTimeStamp: Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
   }
    
    var timeStamp: String {
        return self.formatted(date: .omitted, time: .complete)
    }
    
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
