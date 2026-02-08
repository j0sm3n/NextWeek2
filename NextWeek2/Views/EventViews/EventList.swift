//
//  EventList.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import EventKit
import SwiftUI

struct EventList: View {
    @Environment(EventStoreManager.self) var storeManager
    @Environment(AgentStore.self) var agentStore
    
    @State private var selectedEvent: EKEvent?
    @State private var showEventEditViewController = false

    @State var showSettings: Bool = false
    
    var filteredEventsByDay: [(date: Date, events: [EKEvent])] {
        let agentCalendarIDs: Set<String> = Set(agentStore.agents.map { $0.calendar.calendarIdentifier })
        guard !agentCalendarIDs.isEmpty else { return [] }
        
        let filteredEvents = storeManager.events.filter {
            agentCalendarIDs.contains($0.calendar.calendarIdentifier)
        }
        
        // Grouped by day
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEvents) { event in
            calendar.startOfDay(for: event.startDate)
        }
        
        // Sort by date
        let eventsByDay = grouped.sorted { $0.key < $1.key }.map { (date: $0.key, events: $0.value) }

        return eventsByDay
    }

    var body: some View {
        VStack {
            if storeManager.events.isEmpty {
                MessageView(message: .events)
            } else {
                List {
                    ForEach(filteredEventsByDay, id: \.date) { day in
                        GroupBox {
                            ForEach(day.events, id: \.eventIdentifier) { event in
                                EventRow(event: event)
                                    .onTapGesture {
                                        selectedEvent = event
                                        showEventEditViewController.toggle()
                                    }
                            }
                        } label: {
                            Text(day.date.toLongDateString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundStyle(.primary)
                        .backgroundStyle(.gray.opacity(0.2))
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Ajustes", systemImage: "gear") {
                            showSettings = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEventEditViewController) {
            EventEditViewController(event: $selectedEvent, eventStore: storeManager.dataStore.eventStore)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

fileprivate struct EventRow: View {
    let event: EKEvent

    var body: some View {
        HStack {
            Circle()
                .fill(event.color)
                .frame(width: 8, height: 8)
            Text(event.title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            Spacer()
            Text(event.fromStartDateToEndDateString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
    }
}
