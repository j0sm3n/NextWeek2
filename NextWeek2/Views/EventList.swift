//
//  EventList.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import EventKit
import SwiftUI

struct EventList: View {
    @Environment(EventStoreManager.self) var storeManager
    @State private var shouldPresentError: Bool = false
    @State private var alertMessage: String?
    @State private var alertTitle: String?
    @State var selection: Set<EKEvent> = []
    @State var editMode: EditMode = .inactive

    /*
        Displays a list of events that occur within this month in all the user's calendars. Removes an event from Calendar when the user deletes it
        from the list.
    */
    var body: some View {
        VStack {
            if storeManager.events.isEmpty {
                MessageView(message: .events)
            } else {
                List(selection: $selection) {
                    ForEach(storeManager.events, id: \.self) { event in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(event.title)
                                .foregroundStyle(.primary)
                                .font(.headline)
                            HStack {
                                Text(event.startDate, style: .date)
                                    .foregroundStyle(.primary)
                                    .font(.caption)
                                Text("a las")
                                    .foregroundStyle(.primary)
                                    .font(.caption)
                                Text(event.startDate, style: .date)
                                    .foregroundStyle(.primary)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .toolbar(content: toolbarContent)
                .environment(\.editMode, $editMode)
            }
        }
        .alertErrorMessage(message: alertMessage, title: alertTitle, isPresented: $shouldPresentError)
    }
    
    /// Delete the selected event from Calendar.
    func removeEvents(_ events: [EKEvent]) {
        Task {
            do {
                try await storeManager.removeEvents(events)
                selection.removeAll()
            } catch {
                showError(error, title: "Fallo al borrar.")
            }
        }
    }
    
    func showError(_ error: Error, title: String) {
        alertTitle = title
        alertMessage = error.localizedDescription
        shouldPresentError = true
    }
}

#Preview {
    EventList()
        .environment(EventStoreManager())
}
