//
//  Date+Extension.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import Foundation

extension Date {
    /// A week from the current date.
    var twoWeeksLater: Date {
        Calendar.current.date(byAdding: .day, value: 14, to: Date.now) ?? Date()
    }
    
    var toDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: self)
    }
    
    var toLongDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy"
        return formatter.string(from: self)
    }
    
    var toTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var toDayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self).capitalized
    }
}
