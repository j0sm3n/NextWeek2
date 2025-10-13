//
//  AgentPicker.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 24/8/25.
//

import SwiftUI

struct AgentPicker: View {
    @Environment(AgentStore.self) var agentStore

    var body: some View {
        Picker(selection: Bindable(agentStore).selectedAgent) {
            ForEach(agentStore.agents) { agent in
                Text(agent.cf, format: .number)
                    .tag(agent)
            }
        } label: {
            Text("Selecciona un agente")
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

#Preview {
    AgentPicker()
        .environment(AgentStore())
}
