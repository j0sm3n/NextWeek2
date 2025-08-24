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
    
    @State private var shouldPresentError: Bool = false
    @State private var alertTitle: String?
    
    @State var selection: Set<EKEvent> = []
    @State var editMode: EditMode = .inactive
    @State private var selectedEvent: EKEvent?
    @State private var showEventEditViewController = false
    
    @State private var selectedAgent: Agent = Agent.agents.first!
    
    @State private var filename: URL?
    @State var showFileChooser: Bool = false
    
    var filteredEvents: [EKEvent] {
        storeManager.events.filter {
            $0.calendar.calendarIdentifier == selectedAgent.calendarIdentifier
        }
    }

    /*
        Displays a list of events that occur within next two weeks in all the selected user's calendars.
        Removes an event from Calendar when the user deletes it from the list.
    */
    var body: some View {
        VStack {
            if storeManager.events.isEmpty {
                MessageView(message: .events)
            } else {
                AgentPicker(selectedAgent: $selectedAgent)

                List(selection: $selection) {
                    ForEach(filteredEvents, id: \.self) { event in
                        EventRow(event: event)
                            .onTapGesture {
                                selectedEvent = event
                                showEventEditViewController.toggle()
                            }
                    }
                }
                .toolbar(content: toolbarContent)
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
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
    }
    
    /// Delete the selected event from Calendar.
    func removeEvents(_ events: [EKEvent]) {
        Task {
            do {
                try await storeManager.removeEvents(events)
                selection.removeAll()
            } catch {
                showAlert(title: "Ha ocurrido un error al borrar los eventos seleccionados.")
            }
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
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 7) {
                Text(event.startDate.formatted(.dateTime.weekday().day().month().year()))
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Text(event.title)
                    .foregroundStyle(.primary)
                    .font(.headline)
            }
            Spacer()
            VStack {
                Spacer()
                Text(event.fromStartDateToEndDateString)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .contentShape(.rect)
    }
}
