//
//  Agent.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import Foundation
import EventKit

struct Agent: Hashable, Codable {
    let cf: Int
    let name: String
    let category: Category
    let location: Location
    var calendar: AgentCalendar
}

extension Agent: Identifiable {
    var id: Int { cf }
}
