//
//  Event.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 18/10/25.
//

import EventKit

struct Event {
    var id: UUID
    var title: String
    let startDate: Date
    var endDate: Date?
    
    init(shift: Shift, date: Date) {
        self.id = UUID()
        self.title = shift.name
        if let startTime = shift.startTime, let duration = shift.duration {
            let startDate = Calendar.current.startOfDay(for: date).addingTimeInterval(startTime)
            let endDate = startDate.addingTimeInterval(duration)
            self.startDate = startDate
            self.endDate = endDate
        } else {
            self.startDate = date
        }
    }
    
    func addEvent(store: EKEventStore, calendar: EKCalendar) -> EKEvent {
        var eventToSave = self
        eventToSave.title = "Turno \(self.title)"
        let newEvent = EKEvent(event: eventToSave, eventStore: store, calendar: calendar)
        return newEvent
    }
}
