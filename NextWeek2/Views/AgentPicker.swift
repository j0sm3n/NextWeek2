//
//  AgentPicker.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 24/8/25.
//

import SwiftUI

struct AgentPicker: View {
    @Binding var selectedAgent: Agent

    var body: some View {
        Picker(selection: $selectedAgent) {
            ForEach(Agent.agents) { agent in
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
    @Previewable @State var agent: Agent = Agent.agents.first!
    AgentPicker(selectedAgent: $agent)
}
