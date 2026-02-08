//
//  ScheduleTableView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 8/2/26.
//

import SwiftUI

struct ScheduleTableView: View {
    @Environment(AgentStore.self) var agentStore
    let schedule: [Agent: [Event]]
    
    var body: some View {
        GeometryReader { geometry in
            let columnWidth = (geometry.size.width - 162) / CGFloat(agentStore.agents.count)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    ScheduleHeaderView(columnWidth: columnWidth)
                    
                    // Date and shifts rows
                    ForEach(0..<7, id: \.self) { dayIndex in
                        ScheduleDayRowView(
                            dayIndex: dayIndex,
                            schedule: schedule,
                            columnWidth: columnWidth
                        )
                    }
                }
            }
            .padding(.top)
        }
    }
}

private struct ScheduleHeaderView: View {
    @Environment(AgentStore.self) var agentStore
    let columnWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            Text("Fecha")
                .frame(width: 130, alignment: .leading)
            
            ForEach(agentStore.agents) { agent in
                Text(agent.name)
                    .frame(width: columnWidth, alignment: .leading)
            }
        }
        .font(.title3)
        .fontWeight(.thin)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct ScheduleDayRowView: View {
    @Environment(AgentStore.self) var agentStore
    let dayIndex: Int
    let schedule: [Agent: [Event]]
    let columnWidth: CGFloat
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                // Date column
                if let firstAgent = agentStore.agents.first,
                   let workdays = schedule[firstAgent],
                   dayIndex < workdays.count {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workdays[dayIndex].startDate.toDayOfWeekString)
                        Text(workdays[dayIndex].startDate.toDateString)
                    }
                    .font(.subheadline)
                    .frame(width: 130, alignment: .leading)
                }
                
                // Agent's shift columns
                ForEach(agentStore.agents) { agent in
                    if let events = schedule[agent], dayIndex < events.count {
                        ShiftCellView(
                            event: events[dayIndex],
                            agent: agent,
                            columnWidth: columnWidth
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(dayIndex.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
    }
}

private struct ShiftCellView: View {
    @Environment(AgentStore.self) var agentStore
    let event: Event
    let agent: Agent
    let columnWidth: CGFloat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                
                if let endDate = event.endDate {
                    Text("\(event.startDate.toTimeString) - \(endDate.toTimeString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("")
                }
            }
            .overlay(alignment: .leading) {
                Circle()
                    .fill(agentStore.color(for: agent) ?? .clear)
                    .frame(width: 10, height: 10)
                    .offset(x: -20)
            }
        }
        .frame(width: columnWidth, alignment: .leading)
    }
}
