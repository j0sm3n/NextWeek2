//
//  MainView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(EventStoreManager.self) var storeManager
    @Environment(AgentStore.self) var agentStore
    @Environment(\.modelContext) private var modelContext

    @State private var shouldPresentAlert: Bool = false
    @State private var alertTitle: String?
    @State private var showSettings: Bool = false
    @State private var showNoShiftsWarning: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                switch storeManager.authorizationStatus {
                case .notDetermined:
                    messageView(with: .none)
                case .restricted:
                    messageView(with: .restricted)
                case .denied:
                    messageView(with: .denied)
                case .writeOnly:
                    messageView(with: .upgrade)
                case .authorized:
                    EventList()
                case .fullAccess:
                    EventList()
                @unknown default:
                    fatalError("An error occurs.")
                }
            }
            .alertMessage(title: alertTitle, isPresented: $shouldPresentAlert)
            .alert("Sin datos de turnos", isPresented: $showNoShiftsWarning) {
                Button("Reintentar") {
                    Task {
                        try? await ShiftService.shared.syncIfNeeded(modelContext: modelContext)
                        showNoShiftsWarning = await !ShiftService.shared.hasShifts(modelContext: modelContext)
                    }
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("No se han podido cargar los datos de turnos. Verifica tu conexión a internet e inténtalo de nuevo.")
            }
            .navigationTitle("Próximos Eventos")
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                showSettings = !agentStore.agentsHaveValidCalendar()
                do {
                    try await storeManager.setupEventStore()
                } catch {
                    showAlert(title: "Authorization failed")
                }
                showNoShiftsWarning = await !ShiftService.shared.hasShifts(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    func messageView(with message: Message) -> some View {
        if !shouldPresentAlert {
            MessageView(message: message)
        }
    }

    func showAlert(title: String) {
        alertTitle = title
        shouldPresentAlert = true
    }
}

#Preview {
    MainView()
        .environment(AgentStore())
        .environment(EventStoreManager())
}
