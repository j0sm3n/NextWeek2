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
    
    public static var agents: [Agent] = [
        Agent(cf: 1508, category: .usi, location: .benidorm, calendarIdentifier: "872F3451-507C-4498-87C2-E58200E5CC50"),
        Agent(cf: 2076, category: .maquinista, location: .benidorm, calendarIdentifier: "A7160EBC-02B1-4C30-837D-07D90E596784")
    ]
}
