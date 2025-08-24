//
//  ImportView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import EventKit
import SwiftUI

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(EventStoreManager.self) var storeManager
    
    @State private var shouldPresentAlert: Bool = false
    @State private var alertTitle: String?
    
    @State private var selectedAgent: Agent = Agent.agents.first!
    @State private var week: [WorkDay] = []
    @State private var isLoading: Bool = false
    
    @State private var savedStatus: [Agent: Bool] = [
        Agent.agents[0]: false, Agent.agents[1]: false
    ]
    
    var savedShiftsForSelectedAgent: Bool { savedStatus[selectedAgent] == true }
    var savedShiftsForAllAgents: Bool { Agent.agents.allSatisfy { savedStatus[$0] == true } }
    
    let filename: URL
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AgentPicker(selectedAgent: $selectedAgent)
                
                if isLoading {
                    ProgressView()
                        .padding(.top)
                } else {
                    if week.isEmpty {
                        ContentUnavailableView(
                            "No hay turnos",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text(
                                "No se ha encontrado ningún turno para el agente \(selectedAgent.cf)"
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
                        
                        Button {
                            Task {
                                do {
                                    try await insertEvents()
                                    savedStatus[selectedAgent] = true
                                    if savedShiftsForAllAgents {
                                        dismiss()
                                    }
                                } catch {
                                    showAlert(title: "Ha ocurrido un error al guardar los turnos.")
                                }
                            }
                        } label: {
                            Label(
                                savedShiftsForSelectedAgent ? "Guardado" : "Guardar",
                                systemImage: savedShiftsForSelectedAgent ? "checkmark.circle" : "square.and.arrow.down"
                            )
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(.accent)
                        .disabled(savedShiftsForSelectedAgent)
                        .padding()
                    }
                }
            }
            .navigationTitle(week.isEmpty ? "" : "Turnos del agente \(selectedAgent.cf)")
            .toolbar(content: toolbarContent)
            .alertMessage(title: alertTitle, isPresented: $shouldPresentAlert)
            .task(id: selectedAgent) {
                populateWeek()
            }
        }
    }
    
    private func populateWeek() {
        isLoading = true
        do {
            let shifts = Shift.shiftsFor(category: selectedAgent.category)
            
            let fileManager = FileManager(fileURL: filename, agent: selectedAgent, shifts: shifts)
            try fileManager.getData()
            if let schedule = fileManager.schedule {
                self.week = schedule.week
            }
        } catch {
            showAlert(title: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func insertEvents() async throws {
        let events = week.map { $0.convertToEvent() }
        for event in events {
            if event.startDate != nil {
                try await storeManager.saveEvent(event, calendarIdentifier: selectedAgent.calendarIdentifier)
            }
        }
    }
    
    /// Set up details of the alert message.
    private func showAlert(title: String) {
        alertTitle = title
        shouldPresentAlert = true
    }
}
