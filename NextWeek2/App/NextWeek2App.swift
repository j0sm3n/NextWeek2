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

    let modelContainer: ModelContainer

    init() {
        let schema = Schema([Shift.self])
        modelContainer = try! ModelContainer(for: schema)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(storeManager)
                .environment(agentsStore)
                .modelContainer(modelContainer)
                .task {
                    await storeManager.listenForCalendarChanges()
                    try? await ShiftService.shared.syncIfNeeded(modelContext: modelContainer.mainContext)
                }
        }
    }
}
