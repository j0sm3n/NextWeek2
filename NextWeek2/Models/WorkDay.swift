//
//  WorkDay.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 18/10/25.
//

import Foundation

struct WorkDay {
    let shift: Shift
    let date: Date
    
    func convertToEvent() -> Event {
        if let startTime = shift.startTime, let duration = shift.duration {
            let startDate = Calendar.current.startOfDay(for: date).addingTimeInterval(startTime)
            let endDate = startDate.addingTimeInterval(duration)
            return Event(title: "Turno \(self.shift.name)", startDate: startDate, endDate: endDate)
        } else {
            return Event(title: "Turno \(self.shift.name)")
        }
    }
}
