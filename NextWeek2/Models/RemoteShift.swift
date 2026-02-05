//
//  RemoteShift.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 5/2/26.
//

import Foundation

struct RemoteShiftsResponse: Codable {
    let metadata: ShiftsMetadata
    let shiftCategories: [ShiftCategoryDTO]
}

struct ShiftsMetadata: Codable {
    let updatedAt: String
    let version: String
}

struct ShiftCategoryDTO: Codable {
    let category: String
    let residence: String
    let shifts: [ShiftDTO]
}

struct ShiftDTO: Codable {
    let name: String
    let startTime: String
    let duration: Int

    var startTimeInterval: Double {
        let components = startTime.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return 0
        }
        return Double((hours * 3600) + (minutes * 60))
    }

    var durationInterval: Double {
        Double(duration * 60)
    }
}
