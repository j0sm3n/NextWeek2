//
//  Shift.swift
//  NextWeek
//
//  Created by Jose Antonio Mendoza on 4/4/24.
//

import Foundation
import SwiftData

@Model
final class Shift {
    var name: String
    var startTime: Double
    var duration: Double
    var category: String
    var residence: String

    init(name: String, startTime: Double = 0, duration: Double = 0, category: String = "", residence: String = "") {
        self.name = name
        self.startTime = startTime
        self.duration = duration
        self.category = category
        self.residence = residence
    }
}

extension Shift {
    static func shiftsFor(category: Category, location: Location, from context: ModelContext) -> [Shift] {
        let categoryString = category.rawValue
        let locationString = location.rawValue
        let predicate = #Predicate<Shift> {
            $0.category == categoryString && $0.residence == locationString
        }
        let descriptor = FetchDescriptor<Shift>(predicate: predicate)
        return (try? context.fetch(descriptor)) ?? []
    }
}
