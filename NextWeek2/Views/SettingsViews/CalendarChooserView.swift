//
//  CalendarChooserView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 12/10/25.
//

import SwiftUI
import EventKit

struct CalendarChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EventStoreManager.self) var storeManager
    @Environment(AgentStore.self) var agentStore
    @State private var calendars: [EKCalendar] = []
    
    var body: some View {
        List {
            ForEach(calendars, id: \.self) { calendar in
                Button {
                    agentStore.selectedAgent.calendar = AgentCalendar(title: calendar.title, calendarIdentifier: calendar.calendarIdentifier)
                    agentStore.updateCalendarAgent()
                    dismiss()
                } label: {
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color(cgColor: calendar.cgColor))
                        Text(calendar.title)
                        if calendar.calendarIdentifier == agentStore.selectedAgent.calendar.calendarIdentifier {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .task {
            calendars = storeManager.dataStore.eventStore.calendars(for: .event)
        }
        .navigationTitle("Agente \(agentStore.selectedAgent.cf)")
    }
}

#Preview {
    CalendarChooserView()
        .environment(EventStoreManager())
        .environment(AgentStore())
}
