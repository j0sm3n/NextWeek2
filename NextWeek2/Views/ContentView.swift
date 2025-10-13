//
//  ContentView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 1/5/25.
//

import SwiftUI

struct ContentView: View {
    @State private var storeManager = EventStoreManager()
    @State private var agentsStore = AgentStore()
    
    var body: some View {
        if agentsStore.agentsHaveValidCalendar() {
            MainView()
                .environment(storeManager)
                .environment(agentsStore)
                .task {
                    await storeManager.listenForCalendarChanges()
                }
        } else {
            SettingsView()
                .environment(storeManager)
                .environment(agentsStore)
        }
        
    }
}

#Preview {
    ContentView()
        .environment(EventStoreManager())
        .environment(AgentStore())
}
