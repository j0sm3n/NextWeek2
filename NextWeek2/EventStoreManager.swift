//
//  EventStoreManager.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 1/5/25.
//

import EventKit

@MainActor
@Observable
final class EventStoreManager {
    /// Contains fetched events when the app receives a full-acces authorization status.
    var events: [EKEvent]
    
    /// Specifies the authorization status for the app.
    var authorizationStatus: EKAuthorizationStatus
    
    let dataStore: EventDataStore
    
    init(store: EventDataStore = EventDataStore()) {
        self.dataStore = store
        self.events = []
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    var isWriteOnlyOrFullAccessAuthorized: Bool {
        ((authorizationStatus == .writeOnly) || (authorizationStatus == .fullAccess))
    }
    
    /*
        Listens for event store changes, which are always posted on the main thread.
        When the app receives a full access authorization status, it fetches all
        events occuring within a month in all the user's calendars.
    */
    func listenForCalendarChanges() async {
        let center = NotificationCenter.default
        let notifications = center
            .notifications(named: .EKEventStoreChanged)
            .map({ (notification: Notification) in notification.name })
        
        for await _ in notifications {
            guard await dataStore.isFullAccessAuthorized else { return }
            await self.fetchLatestEvents()
        }
    }
    
    func setupEventStore() async throws {
        let response = try await dataStore.verifyAuthorizationStatus()
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if response {
            await fetchLatestEvents()
        }
    }
    
    func fetchLatestEvents() async {
        let latestEvents = await dataStore.fetchEvents()
        self.events = latestEvents
    }
    
    func removeEvents(_ events: [EKEvent]) async throws {
        try await dataStore.removeEvents(events)
    }
    
    func saveEvent(_ event: Event, calendar: EKCalendar) async throws {
        try await dataStore.addEvent(event, toCalendar: calendar)
    }
}
