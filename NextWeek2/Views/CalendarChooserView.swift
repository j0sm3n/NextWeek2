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
    @State private var calendar: EKCalendar?
    
    var body: some View {
        List {
            ForEach(calendars, id: \.self) { calendar in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color(cgColor: calendar.cgColor))
                    Text(calendar.title)
                    Spacer()
                    Button("Select") {
                        agentStore.selectedAgent.calendar = AgentCalendar(title: calendar.title, calendarIdentifier: calendar.calendarIdentifier)
                        agentStore.updateCalendarAgent()
                        dismiss()
                    }
                }
            }
        }
        .task {
            calendars = storeManager.dataStore.eventStore.calendars(for: .event)
        }
    }
}

#Preview {
    CalendarChooserView()
        .environment(EventStoreManager())
        .environment(AgentStore())
}
