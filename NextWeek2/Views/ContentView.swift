//
//  ContentView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 1/5/25.
//

import SwiftUI

struct ContentView: View {
    @State private var storeManager = EventStoreManager()

    var body: some View {
        MainView()
            .environment(storeManager)
            .task {
                await storeManager.listenForCalendarChanges()
            }
    }
}

#Preview {
    ContentView()
        .environment(EventStoreManager())
}
