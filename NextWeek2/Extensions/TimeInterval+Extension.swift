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
    
    var abbreviatedTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self) ?? ""
    }
    
    var positionalTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .positional
        return formatter.string(from: self) ?? ""
    }
    
    static func weeks(_ weeks: Double) -> TimeInterval {
        return weeks * TimeInterval.week
    }
    
    static var week: TimeInterval {
        return 7 * 24 * 60 * 60
    }
}
