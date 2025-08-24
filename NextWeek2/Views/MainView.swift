//
//  MainView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

struct MainView: View {
    @Environment(EventStoreManager.self) var storeManager
    @State private var shouldPresentAlert: Bool = false
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
    
    /// Set up details of the alert message.
    func showAlert(title: String) {
        alertTitle = title
        shouldPresentAlert = true
    }
}

#Preview {
    MainView()
        .environment(EventStoreManager())
}
