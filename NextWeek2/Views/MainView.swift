//
//  MainView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

struct MainView: View {
    @Environment(EventStoreManager.self) var storeManager
    @State private var shouldPresentError: Bool = false
    
    @State private var alertMessage: String?
    @State private var alertTitle: String?
    
    /*
         The app first verifies the authorization status for Calendar events.
         If the user authorized full access to Calendar, the app displays a
         list of events that occur within this month in all the user's calendars.
         If the user denied or restricted access, the app provides the reason.
     */
    var body: some View {
        NavigationStack {
            VStack {
                switch storeManager.authorizationStatus {
                case .notDetermined:
                    MessageView(message: .none)
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
            .alertErrorMessage(message: alertMessage, title: alertTitle, isPresented: $shouldPresentError)
            .navigationTitle("Próximos Eventos")
            .task {
                do {
                    try await storeManager.setupEventStore()
                } catch {
                    showError(error, title: "Authorization failed")
                }
            }
        }
    }
    
    @ViewBuilder
    func messageView(with message: Message) -> some View {
        if !shouldPresentError {
            MessageView(message: message)
        }
    }
    
    /// Set up details of the alert message.
    func showError(_ error: Error, title: String) {
        alertTitle = title
        alertMessage = error.localizedDescription
        shouldPresentError = true
    }
}

#Preview {
    MainView()
        .environment(EventStoreManager())
}
