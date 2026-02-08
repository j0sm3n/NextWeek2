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
                        GeometryReader { geometry in
                            let columnWidth = (geometry.size.width - 162) / CGFloat(agentStore.agents.count)
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    // Header
                                    HStack(spacing: 0) {
                                        Text("Fecha")
                                            .frame(width: 130, alignment: .leading)
                                        
                                        ForEach(agentStore.agents) { agent in
                                            Text(agent.name)
                                                .frame(width: columnWidth, alignment: .leading)
                                        }
                                    }
                                    .font(.title3)
                                    .fontWeight(.thin)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    
                                    // Date and shifts rows
                                    ForEach(0..<7, id: \.self) { dayIndex in
                                        VStack {
                                            HStack(spacing: 0) {
                                                // Date column
                                                if let firstAgent = agentStore.agents.first,
                                                   let workdays = schedule[firstAgent],
                                                   dayIndex < workdays.count {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(workdays[dayIndex].startDate.toDayOfWeekString)
                                                        Text(workdays[dayIndex].startDate.toDateString)
                                                    }
                                                    .font(.subheadline)
                                                    .frame(width: 130, alignment: .leading)
                                                }
                                                
                                                // Agent's shift columns
                                                ForEach(agentStore.agents) { agent in
                                                    if let events = schedule[agent], dayIndex < events.count {
                                                        HStack {
                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text(events[dayIndex].title)
                                                                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                                                                if let endDate = events[dayIndex].endDate {
                                                                    Text("\(events[dayIndex].startDate.toTimeString) - \(endDate.toTimeString)")
                                                                        .font(.caption)
                                                                        .foregroundColor(.secondary)
                                                                } else {
                                                                    Text("")
                                                                }
                                                            }
                                                            .overlay(alignment: .leading) {
                                                                Circle()
                                                                    .fill(agentStore.color(for: agent) ?? .clear)
                                                                    .frame(width: 10, height: 10)
                                                                    .offset(x: -20)
                                                            }
                                                        }
                                                        .frame(width: columnWidth, alignment: .leading)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                        }
                                        .background(dayIndex.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
                                    }
                                }
                            }
                            .padding(.top)
                        }
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
