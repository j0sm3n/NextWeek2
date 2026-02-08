import Foundation
import SwiftData
import Testing
@testable import NextWeek2

@Suite("ShiftService Sync Tests")
struct ShiftServiceSyncTests {

    // Helper to create an in-memory model context
    func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Shift.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    func makeSampleResponse() -> RemoteShiftsResponse {
        let metadata = ShiftsMetadata(updatedAt: "2026-02-07T12:00:00Z", version: "1.0")
        let day = ShiftDTO(name: "D", startTime: "08:00", duration: 480)
        let night = ShiftDTO(name: "N", startTime: "20:00", duration: 480)
        let cat = ShiftCategoryDTO(category: "Maquinista", residence: "Benidorm", shifts: [day, night])
        return RemoteShiftsResponse(metadata: metadata, shiftCategories: [cat])
    }

    @Test("Preserves user-created shifts on sync")
    func preservesUserCreatedShifts() async throws {
        let context = try makeInMemoryContext()
        let service = ShiftService.shared

        // Seed with a user-created shift and a non-user-created shift
        let userShift = Shift(name: "Personalizado", startTime: 0, duration: 0, category: "Maquinista", residence: "Benidorm")
          userShift.isUserCreated = true
        let remoteShiftOld = Shift(name: "Antiguo", startTime: 100, duration: 200, category: "Maquinista", residence: "Benidorm")
        remoteShiftOld.isUserCreated = false
        context.insert(userShift)
        context.insert(remoteShiftOld)
        try context.save()

        // Perform update with new remote data
        let response = makeSampleResponse()
        try await service.applyRemoteResponseForTesting(response, modelContext: context)

        // Fetch all shifts
        let all = try context.fetch(FetchDescriptor<Shift>())

        // Assert user-created shift still exists
        #expect(all.contains(where: { $0.name == "Personalizado" && $0.isUserCreated }))

        // Assert non-user-created old shift was removed
        #expect(!all.contains(where: { $0.name == "Antiguo" }))

        // Assert new remote shifts were inserted
        #expect(all.contains(where: { $0.name == "D" }))
        #expect(all.contains(where: { $0.name == "N" }))
    }

    @Test("Replaces all non-user shifts with new remote set")
    func replacesNonUserShifts() async throws {
        let context = try makeInMemoryContext()
        let service = ShiftService.shared

        // Seed with multiple non-user-created shifts
        let old1 = Shift(name: "A1", startTime: 0, duration: 0, category: "Maquinista", residence: "Benidorm")
        let old2 = Shift(name: "A2", startTime: 0, duration: 0, category: "Maquinista", residence: "Benidorm")
        context.insert(old1)
        context.insert(old2)
        try context.save()

        // Update with sample response
        let response = makeSampleResponse()
        try await service.applyRemoteResponseForTesting(response, modelContext: context)

        let all = try context.fetch(FetchDescriptor<Shift>())

        // Old non-user shifts should be gone
        #expect(!all.contains(where: { $0.name == "A1" }))
        #expect(!all.contains(where: { $0.name == "A2" }))

        // New remote set present
        #expect(all.contains(where: { $0.name == "D" }))
        #expect(all.contains(where: { $0.name == "N" }))
    }
}
