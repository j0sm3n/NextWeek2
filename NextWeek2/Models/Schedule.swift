//
//  Schedule.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 4/5/25.
//

import EventKit

struct Schedule {
    let agentCF: Int
    let week: [WorkDay]
}

struct WorkDay {
    let shift: Shift
    let date: Date
}

struct Event {
    let title: String
    let startDate: Date?
    let endDate: Date?
    
    init(title: String, startDate: Date? = nil, endDate: Date? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
}

extension WorkDay {
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

extension Event {
    /// Create an event in the user's calendar with the event details.
    func addEvent(store: EKEventStore, calendar: EKCalendar) -> EKEvent {
        let newEvent = EKEvent(event: self, eventStore: store, calendar: calendar)
        return newEvent
    }
}
