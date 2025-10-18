//
//  SettingsView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 10/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EventStoreManager.self) var storeManager
    @Environment(AgentStore.self) var agentStore
    @State private var isPresented: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                ForEach(agentStore.agents) { agent in
                    Section(agent.cf.formatted()) {
                        LabeledContent("Agente", value: agent.cf, format: .number)
                        LabeledContent("Residencia", value: agent.location.rawValue)
                        LabeledContent("Categoría", value: agent.category.rawValue)
                        LabeledContent("Calendario") {
                            Button {
                                agentStore.selectedAgent = agent
                                isPresented = true
                            } label: {
                                agent.calendar.calendarIdentifier.isEmpty
                                ? Text("\(Text("Seleccionar").foregroundStyle(.red))")
                                : Text(agent.calendar.title)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ajustes")
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    CalendarChooserView()
                }
            }
            .task {
                do {
                    try await storeManager.setupEventStore()
                } catch {
                    print("Authorization failed")
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AgentStore())
}
