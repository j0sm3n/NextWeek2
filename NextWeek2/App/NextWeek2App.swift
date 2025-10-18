//
//  NextWeek2App.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 1/5/25.
//

import SwiftUI

@main
struct NextWeek2App: App {
    @State private var storeManager = EventStoreManager()
    @State private var agentsStore = AgentStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(storeManager)
                .environment(agentsStore)
                .task {
                    await storeManager.listenForCalendarChanges()
                }
        }
    }
}
