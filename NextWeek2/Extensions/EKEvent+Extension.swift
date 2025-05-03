//
//  EKEvent+Extension.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import EventKit
import SwiftUI

extension EKEvent: @retroactive Identifiable {
    public var id: String {
        return eventIdentifier
    }
    
    var color: Color {
        return Color(UIColor(cgColor: self.calendar.cgColor))
    }
    
    var durationString: String {
        guard let startDate = self.startDate,
              let endDate = self.endDate else { return "" }
        return "\(startDate.formatted(date: .omitted, time: .shortened))" +
        "-" +
        "\(endDate.formatted(date: .omitted, time: .shortened))"
    }
}
