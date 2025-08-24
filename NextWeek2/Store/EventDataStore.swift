//
//  EventDataStore.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 1/5/25.
//

import EventKit

actor EventDataStore {
    nonisolated let eventStore: EKEventStore
    
    init() {
        self.eventStore = EKEventStore()
    }
    
    var isFullAccessAuthorized: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }
    
    /// Prompts the user for full-access authorization to Calendar
    private func requestFullAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }
    
    /// Verifies the authorization status for the app.
    func verifyAuthorizationStatus() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            return try await requestFullAccess()
        case .restricted:
            throw EventStoreError.restricted
        case .denied:
            throw EventStoreError.denied
        case .fullAccess:
            return true
        case .writeOnly:
            throw EventStoreError.upgrade
        @unknown default:
            throw EventStoreError.unknown
        }
    }
    
    /// Fetches all events occuring within two weeks in all the user's calendars.
    func fetchEvents() -> [EKEvent] {
        guard isFullAccessAuthorized else { return [] }
        let start = Date.now
        let end = start.twoWeeksLater
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate).sortedEventByAscendingDate()
    }
    
    /// Remove an event
    private func removeEvent(_ event: EKEvent) throws {
        try self.eventStore.remove(event, span: .thisEvent, commit: false)
    }
    
    /// Batches all the remove operations.
    func removeEvents(_ events: [EKEvent]) throws {
        do {
            try events.forEach { event in
                try removeEvent(event)
            }
            try eventStore.commit()
        } catch {
            eventStore.reset()
            throw error
        }
    }
    
    /// Create an event with the specified details, then save it to the user's Calendar.
    func addEvent(_ event: Event, toCalendar calendar: EKCalendar) throws {
        let newEvent = event.addEvent(store: eventStore, calendar: calendar)
        try self.eventStore.save(newEvent, span: .thisEvent)
    }
    
    func calendarWithIdentifier(_ calendarIdentifier: String) -> EKCalendar? {
        return eventStore.calendar(withIdentifier: calendarIdentifier)
    }
}
