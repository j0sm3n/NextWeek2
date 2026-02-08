//
//  ImportView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import EventKit
import SwiftData
import SwiftUI

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(EventStoreManager.self) var storeManager
    @Environment(AgentStore.self) var agentStore
    
    @State private var shouldPresentAlert: Bool = false
    @State private var alertTitle: String?
    
    @State private var schedule: [Agent: [Event]] = [:]
    @State private var isLoading: Bool = false
    
    let filename: URL
    
    var dates: [Date] {
        Array(Set(schedule.values.flatMap { events in
            events.compactMap {
                Calendar.current.startOfDay(for: $0.startDate)
            }
        }))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                        .padding(.top)
                } else {
                    if schedule.isEmpty {
                        ContentUnavailableView(
                            "No hay turnos",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text("No se ha encontrado ningún turno")
                        )
                        .offset(y: -60)
                    } else {
                        ScheduleTableView(schedule: schedule)
                    }
                }
            }
            .toolbar(content: toolbarContent)
            .alertMessage(title: alertTitle, isPresented: $shouldPresentAlert)
            .task(id: agentStore.selectedAgent) {
                populateWeek()
            }
        }
    }
    
    private func populateWeek() {
        isLoading = true
        do {
            let fileManager = AppFileManager(fileURL: filename, modelContext: modelContext)
            for agent in agentStore.agents {
                try fileManager.getData(for: agent)
                if !fileManager.week.isEmpty {
                    schedule[agent] = fileManager.week
                }
            }
        } catch {
            showAlert(title: error.localizedDescription)
        }
        isLoading = false
    }
    
    func insertEvents() async throws {
        for agent in agentStore.agents {
            if let events = schedule[agent] {
                for event in events {
                    if event.endDate != nil {
                        try await storeManager.saveEvent(event, calendarIdentifier: agent.calendar.calendarIdentifier)
                    }
                }
            }
        }
    }
    
    /// Set up details of the alert message.
    func showAlert(title: String) {
        alertTitle = title
        shouldPresentAlert = true
    }
}

#Preview {
    @Previewable @State var filename = Bundle.main.url(forResource: "08-09_GSEMANAL_2025", withExtension: "xlsx")!
    ImportView(filename: filename)
        .environment(EventStoreManager())
        .environment(AgentStore())
}
