//
//  MainView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

struct MainView: View {
    @Environment(AgentStore.self) var agentsStore
    @Environment(EventStoreManager.self) var storeManager
    @State private var showSettings: Bool = false
    @State private var shouldPresentAlert: Bool = false
    @State private var alertTitle: String?
    
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
            .navigationTitle("Próximos Eventos")
            .task {
                showSettings = !agentsStore.agentsHaveValidCalendar()
                do {
                    try await storeManager.setupEventStore()
                } catch {
                    showAlert(title: "Authorization failed")
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Ajustes", systemImage: "gear") {
                        showSettings = true
                    }
                    
                }
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
