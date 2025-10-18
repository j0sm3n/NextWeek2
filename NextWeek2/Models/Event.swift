//
//  Event.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 18/10/25.
//

import EventKit

struct Event {
    let title: String
    let startDate: Date?
    let endDate: Date?
    
    init(title: String, startDate: Date? = nil, endDate: Date? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
    
    /// Create an event in the user's calendar with the event details.
    func addEvent(store: EKEventStore, calendar: EKCalendar) -> EKEvent {
        let newEvent = EKEvent(event: self, eventStore: store, calendar: calendar)
        return newEvent
    }
}
