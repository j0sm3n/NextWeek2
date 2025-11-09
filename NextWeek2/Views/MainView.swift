//
//  MainView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

struct MainView: View {
    @Environment(EventStoreManager.self) var storeManager
    @Environment(AgentStore.self) var agentStore

    @State private var shouldPresentAlert: Bool = false
    @State private var alertTitle: String?
    @State private var showSettings: Bool = false

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
