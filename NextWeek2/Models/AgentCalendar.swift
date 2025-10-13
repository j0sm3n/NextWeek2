//
//  AgentCalendar.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 12/10/25.
//


struct AgentCalendar: Hashable, Codable {
    var title: String
    var calendarIdentifier: String
    
    init(title: String = "", calendarIdentifier: String = "") {
        self.title = title
        self.calendarIdentifier = calendarIdentifier
    }
}
