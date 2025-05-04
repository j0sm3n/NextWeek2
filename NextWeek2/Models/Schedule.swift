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
    let startDate: Date
    let endDate: Date
}

extension WorkDay {
    func convertToEvent() -> Event {
        let startDate = Calendar.current.startOfDay(for: date).addingTimeInterval(shift.startTime)
        let endDate = startDate.addingTimeInterval(shift.duration)
        
        return Event(title: "Turno \(self.shift.name)", startDate: startDate, endDate: endDate)
    }
}

extension Event {
    /// Create an event in the user's calendar with the event details.
    func addEvent(store: EKEventStore, calendar: EKCalendar) -> EKEvent {
        let newEvent = EKEvent(event: self, eventStore: store, calendar: calendar)
        return newEvent
    }
}
