//
//  NextWeek2App.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 1/5/25.
//

import SwiftData
import SwiftUI

@main
struct NextWeek2App: App {
    @State private var storeManager = EventStoreManager()
    @State private var agentsStore: AgentStore
    @State private var shiftService = ShiftService.shared

    let modelContainer: ModelContainer

    init() {
        // Initialize AgentStore with the shared event store
        let eventStoreManager = EventStoreManager()
        _storeManager = State(initialValue: eventStoreManager)
        _agentsStore = State(initialValue: AgentStore(eventStore: eventStoreManager.dataStore.eventStore))
        
        // Initialize model container
        do {
            let schema = Schema([Shift.self])
            let configuration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .none
            )
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If migration fails, delete the old store and create a new one
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error removing old database: \(error.localizedDescription)")
            }
            
            do {
                let schema = Schema([Shift.self])
                let configuration = ModelConfiguration(
                    schema: schema,
                    cloudKitDatabase: .none
                )
                modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(storeManager)
                .environment(agentsStore)
                .environment(shiftService)
                .modelContainer(modelContainer)
                .task {
                    await storeManager.listenForCalendarChanges()
                }
        }
    }
}
