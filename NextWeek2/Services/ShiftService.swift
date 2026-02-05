//
//  ShiftService.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 5/2/26.
//

import Foundation
import SwiftData

actor ShiftService {
    static let shared = ShiftService()

    private let url = URL(string: "https://raw.githubusercontent.com/j0sm3n/ShiftsData/refs/heads/main/shifts.json")!
    private let lastUpdatedKey = "shiftsLastUpdated"

    func syncIfNeeded(modelContext: ModelContext) async throws {
        let response = try await fetchRemoteShifts()

        let lastUpdated = UserDefaults.standard.string(forKey: lastUpdatedKey)
        guard lastUpdated == nil || response.metadata.updatedAt > lastUpdated! else {
            return
        }

        try modelContext.delete(model: Shift.self)

        for category in response.shiftCategories {
            for shiftDTO in category.shifts {
                let shift = Shift(
                    name: shiftDTO.name,
                    startTime: shiftDTO.startTimeInterval,
                    duration: shiftDTO.durationInterval,
                    category: category.category,
                    residence: category.residence
                )
                modelContext.insert(shift)
            }
        }

        try modelContext.save()
        UserDefaults.standard.set(response.metadata.updatedAt, forKey: lastUpdatedKey)
    }

    func hasShifts(modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Shift>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    private func fetchRemoteShifts() async throws -> RemoteShiftsResponse {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(RemoteShiftsResponse.self, from: data)
    }
}
