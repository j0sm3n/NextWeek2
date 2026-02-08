//
//  TimeInterval+Extension.swift
//  NextWeek
//
//  Created by Jose Antonio Mendoza on 12/3/23.
//

import Foundation

extension TimeInterval {
    init(hour: Int, minute: Int = 0) {
        self = TimeInterval((hour * 3600) + (minute * 60))
    }
    
    /// Formats the time interval as "HH:mm" (e.g., "08:30")
    var formattedAsTime: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    /// Formats the time interval as duration (e.g., "8h" or "8h 30m")
    var formattedAsDuration: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        
        if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    static var week: TimeInterval {
        return 7 * 24 * 60 * 60
    }
}
