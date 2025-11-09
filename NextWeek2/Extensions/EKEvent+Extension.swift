//
//  EKEvent+Extension.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import EventKit
import SwiftUI

extension EKEvent: @retroactive Identifiable {
    public var id: String {
        return eventIdentifier
    }
}

extension EKEvent {
    convenience init(event: Event, eventStore: EKEventStore, calendar: EKCalendar) {
        self.init(eventStore: eventStore)
        self.title = event.title
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.calendar = calendar
        self.timeZone = TimeZone.current
    }
}
    
extension EKEvent {
    var color: Color {
        return Color(UIColor(cgColor: self.calendar.cgColor))
    }
    
    var fromStartDateToEndDateString: String {
        guard let startDate = self.startDate,
              let endDate = self.endDate else { return "" }
        return "\(startDate.toTimeString) - \(endDate.toTimeString)"
    }
}
