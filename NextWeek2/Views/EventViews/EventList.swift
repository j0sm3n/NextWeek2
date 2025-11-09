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
    
    @State private var shouldPresentError: Bool = false
    @State private var alertTitle: String?
    
    @State private var selectedEvent: EKEvent?
    @State private var showEventEditViewController = false

    @State var showSettings: Bool = false
    
    @State private var filename: URL?
    @State var showFileChooser: Bool = false
    
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
                .toolbar(content: toolbarContent)
            }
        }
        .alertMessage(title: alertTitle, isPresented: $shouldPresentError)
        .fileImporter(isPresented: $showFileChooser, allowedContentTypes: [.pdf, .spreadsheet], allowsMultipleSelection: false) { result in
            do {
                let fileUrl = try result.get()
                if fileUrl[0].startAccessingSecurityScopedResource() {
                    self.filename = fileUrl.first
                }
            } catch {
                showAlert(title: "Ha ocurrido un error al importar el archivo.")
            }
        }
        .sheet(item: $filename,
               onDismiss: { filename?.stopAccessingSecurityScopedResource() },
               content: { file in
            ImportView(filename: file)
        })
        .sheet(isPresented: $showEventEditViewController) {
            EventEditViewController(event: $selectedEvent, eventStore: storeManager.dataStore.eventStore)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    /// Set up details of the alert message.
    func showAlert(title: String) {
        alertTitle = title
        shouldPresentError = true
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
