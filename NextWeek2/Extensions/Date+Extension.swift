//
//  Date+Extension.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import Foundation

extension Date {
    /// Two weeks from the current date.
    var twoWeeksLater: Date {
        Calendar.current.date(byAdding: .day, value: 14, to: Date.now) ?? Date()
    }
    
    /// Formats date as "dd/MM" (e.g., "15/02")
    var toDateString: String {
        self.formatted(.dateTime.day(.twoDigits).month(.twoDigits))
    }
    
    /// Formats date as "E, dd MMM yyyy" (e.g., "Fri, 15 Feb 2025")
    var toLongDateString: String {
        self.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year())
    }
    
    /// Formats time as "HH:mm" (e.g., "14:30")
    var toTimeString: String {
        self.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }
    
    /// Returns the capitalized day of the week (e.g., "Viernes")
    var toDayOfWeekString: String {
        self.formatted(.dateTime.weekday(.wide)).capitalized
    }
}
