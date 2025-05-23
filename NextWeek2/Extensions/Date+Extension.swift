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
}
