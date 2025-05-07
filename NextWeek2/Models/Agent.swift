//
//  Agent.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import Foundation

enum Category: String, CaseIterable {
    case maquinista = "Maquinista"
    case usi = "USI"
}

enum Location: String, CaseIterable {
    case benidorm
    case denia
}

struct Agent: Hashable {
    let cf: Int
    let category: Category
    let location: Location
    let calendarIdentifier: String
}

extension Agent: Identifiable {
    var id: Int { cf }
}

extension Agent {
    public static var agents: [Agent] = [
        Agent(cf: 1508, category: .usi, location: .benidorm, calendarIdentifier: "BEB882DA-754E-4F1D-A336-F5F161C16926"),
        Agent(cf: 2076, category: .maquinista, location: .benidorm, calendarIdentifier: "0264FDAE-34E9-449A-AAA7-147AFE593846")
    ]
    
    func agentWithCF(_ cf: Int) -> Agent? {
        Self.agents.first { $0.cf == cf }
    }
}
