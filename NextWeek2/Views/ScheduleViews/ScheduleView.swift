//
//  ScheduleView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import EventKit
import SwiftUI

struct ScheduleView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(EventStoreManager.self) var storeManager
    
    @State private var shouldPresentError: Bool = false
    @State private var alertMessage: String?
    @State private var alertTitle: String?
    
    @State private var week: [WorkDay] = []
    @State private var isLoading: Bool = false
    
    let agent: Agent
    let filename: URL
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView()
                        .padding(.top)
                } else {
                    if week.isEmpty {
                        ContentUnavailableView(
                            "No hay turnos",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text(
                                "No se ha encontrado ningún turno para el agente \(agent.cf)"
                            )
                        )
                        .offset(y: -60)
                    } else {
                        List {
                            ForEach(week, id: \.date) { workDay in
                                CardView(date: workDay.date, shift: workDay.shift.name)
                                    .listRowSpacing(0)
                            }
                        }
                        .listStyle(.plain)
                        .padding(.top, 48)
                        
                        Button("Guardar") {
                            Task {
                                do {
                                    try await insertEvents()
                                    dismiss()
                                } catch {
                                    showError(error, title: "Ha ocurrido un error al guardar los turnos.")
                                }
                            }
                        }
                        .buttonStyle(.myAppPrimaryButton)
                        .padding()
                    }
                }
            }
            .navigationTitle(week.isEmpty ? "" : "Turnos del agente \(agent.cf)")
            .toolbar(content: toolbarContent)
            .alertErrorMessage(message: alertMessage, title: alertTitle, isPresented: $shouldPresentError)
            .task {
                populateWeek()
            }
        }
    }
    
    private func populateWeek() {
        isLoading = true
        do {
            let shifts = Shift.shiftsFor(category: agent.category)
            
            let fileManager = FileManager(fileURL: filename, agent: agent, shifts: shifts)
            try fileManager.getData()
            if let schedule = fileManager.schedule {
                self.week = schedule.week
            }
        } catch {
            showError(error, title: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func insertEvents() async throws {
        let events = week.map { $0.convertToEvent() }
        for event in events {
            if event.startDate != nil {
                try await storeManager.saveEvent(event, calendarIdentifier: agent.calendarIdentifier)
            }
        }
    }
    
    private func showError(_ error: Error, title: String) {
        alertTitle = title
        alertMessage = error.localizedDescription
        shouldPresentError = true
    }
}
