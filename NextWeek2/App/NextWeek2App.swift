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
    @State private var agentsStore = AgentStore()
    @State private var shiftService = ShiftService.shared

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Shift.self])
            let configuration = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
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
