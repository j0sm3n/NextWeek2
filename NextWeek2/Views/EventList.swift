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
    @State private var alertMessage: String?
    @State private var alertTitle: String?
    @State var selection: Set<EKEvent> = []
    @State var editMode: EditMode = .inactive
    @State private var selectedAgent: Agent?
    @AppStorage("selectedAgent") var selectedAgentCF: Int = 0
    
    var filteredEvents: [EKEvent] {
        guard let agent = selectedAgent else {
            return storeManager.events
        }
        return storeManager.events.filter {
            $0.calendar.calendarIdentifier == agent.calendarIdentifier
        }
    }

    /*
        Displays a list of events that occur within next seven days in all the selected user's calendars.
        Removes an event from Calendar when the user deletes it from the list.
    */
    var body: some View {
        VStack {
            if storeManager.events.isEmpty {
                MessageView(message: .events)
            } else {
                Picker(selection: $selectedAgent) {
                    ForEach(Agent.agents, id: \.cf) { agent in
                        Text(agent.cf, format: .number)
                            .tag(agent)
                    }
                } label: {
                    
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedAgent) { _, newValue in
                    selectedAgentCF = newValue?.cf ?? 0
                }

                List(selection: $selection) {
                    ForEach(filteredEvents) { event in
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
                                Text(event.durationString)
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .toolbar(content: toolbarContent)
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
            }
        }
        .alertErrorMessage(message: alertMessage, title: alertTitle, isPresented: $shouldPresentError)
        .task {
            selectedAgent = Agent.agents.first(where: { $0.cf == selectedAgentCF }) ?? Agent.agents.first!
        }
    }
    
    /// Delete the selected event from Calendar.
    func removeEvents(_ events: [EKEvent]) {
        Task {
            do {
                try await storeManager.removeEvents(events)
                selection.removeAll()
            } catch {
                showError(error, title: "Fallo al borrar.")
            }
        }
    }
    
    func showError(_ error: Error, title: String) {
        alertTitle = title
        alertMessage = error.localizedDescription
        shouldPresentError = true
    }
}

#Preview {
    EventList()
        .environment(EventStoreManager())
}
