//
//  AgentStore.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 10/10/25.
//

import SwiftUI
import Observation
import EventKit

@Observable
final class AgentStore {
    var agents: [Agent] = []
    var selectedAgent: Agent?
    
    private let userDefaults: UserDefaults = .standard
    private let agentsKey: String = "agents"
    
    // Event store instance passed from EventStoreManager
    private let eventStore: EKEventStore
    
    // Cache for calendar colors to avoid repeated lookups
    private var colorCache: [String: Color] = [:]
    
    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
        self.agents = getAgents()
        self.selectedAgent = agents.first
        refreshColorCache()
    }
    
    func agentWithCF(_ cf: Int) -> Agent? {
        agents.first { $0.cf == cf }
    }
    
    private func getAgents() -> [Agent] {
        if let agentsData = userDefaults.data(forKey: agentsKey) {
            if let agents = try? JSONDecoder().decode([Agent].self, from: agentsData) {
                return agents.sorted { $0.cf < $1.cf }
            }
        }
        return [
            Agent(cf: 1508, name: "Itziar", category: .usi, location: .benidorm, calendar: .init()),
            Agent(cf: 2076, name: "Jose", category: .maquinista, location: .benidorm, calendar: .init())
        ]
    }
    
    func agentsHaveValidCalendar() -> Bool {
        var agentsHaveValidCalendar: Bool = false
        let calendars = eventStore.calendars(for: .event)
        let calendarsById: [String: EKCalendar] = Dictionary(uniqueKeysWithValues: calendars.map { ($0.calendarIdentifier, $0) })
        for agent in agents {
            if let _ = calendarsById[agent.calendar.calendarIdentifier] {
                agentsHaveValidCalendar = true
            } else {
                agentsHaveValidCalendar = false
                break
            }
        }
        return agentsHaveValidCalendar
    }
    
    private func updateAgents() {
        if let agentsData = try? JSONEncoder().encode(agents) {
            userDefaults.set(agentsData, forKey: agentsKey)
        }
    }
    
    func updateCalendarAgent() {
        if let selectedAgent, let index = agents.firstIndex(where: { $0.cf == selectedAgent.cf }) {
            agents[index].calendar.title = selectedAgent.calendar.title
            agents[index].calendar.calendarIdentifier = selectedAgent.calendar.calendarIdentifier
            updateAgents()
            updateColorCache()
        }
    }
    
    func color(for agent: Agent) -> Color? {
        // Return cached color if available
        if let cachedColor = colorCache[agent.calendar.calendarIdentifier] {
            return cachedColor
        }
        
        // Otherwise fetch and cache
        guard let calendar = eventStore.calendar(withIdentifier: agent.calendar.calendarIdentifier) else {
            return nil
        }
        
        let color = Color(cgColor: calendar.cgColor)
        colorCache[agent.calendar.calendarIdentifier] = color
        return color
    }
    
    /// Refreshes the color cache for all agent calendars
    private func refreshColorCache() {
        colorCache.removeAll()
        for agent in agents {
            if let calendar = eventStore.calendar(withIdentifier: agent.calendar.calendarIdentifier) {
                colorCache[agent.calendar.calendarIdentifier] = Color(cgColor: calendar.cgColor)
            }
        }
    }
    
    /// Call this when agents or their calendars change
    func updateColorCache() {
        refreshColorCache()
    }
}
