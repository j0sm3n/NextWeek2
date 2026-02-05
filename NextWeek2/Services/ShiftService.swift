//
//  ShiftService.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 5/2/26.
//

import Foundation
import SwiftData

enum ShiftServiceError: LocalizedError {
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case noDataAvailable
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .decodingError:
            return "Error al procesar los datos de turnos."
        case .noDataAvailable:
            return "No hay datos de turnos disponibles."
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        }
    }
}

@MainActor
@Observable
final class ShiftService {
    static let shared = ShiftService()

    private(set) var isLoading = false
    private(set) var lastError: ShiftServiceError?
    private(set) var hasShifts = false

    private let remoteURL = URL(string: "https://raw.githubusercontent.com/j0sm3n/ShiftsData/refs/heads/main/shifts.json")!
    private let lastUpdatedKey = "shiftsLastUpdated"
    private let etagKey = "shiftsETag"

    private init() {}

    /// Syncs shifts only if remote data is newer than local
    func syncIfNeeded(modelContext: ModelContext) async {
        isLoading = true
        lastError = nil

        defer {
            isLoading = false
            updateHasShifts(modelContext: modelContext)
        }

        do {
            // First check if we need to fetch at all using HEAD request
            let shouldFetch = await shouldFetchRemoteData()

            guard shouldFetch else {
                return
            }

            let response = try await fetchRemoteShifts()

            // Compare versions before updating
            let lastUpdated = UserDefaults.standard.string(forKey: lastUpdatedKey)
            guard lastUpdated == nil || response.metadata.updatedAt > lastUpdated! else {
                return
            }

            try await updateLocalShifts(from: response, modelContext: modelContext)

        } catch let error as ShiftServiceError {
            lastError = error
        } catch {
            lastError = .networkError(underlying: error)
        }
    }

    /// Force sync regardless of cache state
    func forceSync(modelContext: ModelContext) async {
        isLoading = true
        lastError = nil

        defer {
            isLoading = false
            updateHasShifts(modelContext: modelContext)
        }

        do {
            let response = try await fetchRemoteShifts()
            try await updateLocalShifts(from: response, modelContext: modelContext)
        } catch let error as ShiftServiceError {
            lastError = error
        } catch {
            lastError = .networkError(underlying: error)
        }
    }

    func updateHasShifts(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Shift>()
        hasShifts = (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    // MARK: - Private Methods

    private func shouldFetchRemoteData() async -> Bool {
        // If we have no local data, always fetch
        guard UserDefaults.standard.string(forKey: lastUpdatedKey) != nil else {
            return true
        }

        // Use HEAD request to check if data changed via ETag
        var request = URLRequest(url: remoteURL)
        request.httpMethod = "HEAD"

        if let storedETag = UserDefaults.standard.string(forKey: etagKey) {
            request.setValue(storedETag, forHTTPHeaderField: "If-None-Match")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return true
            }

            // 304 Not Modified means we don't need to fetch
            if httpResponse.statusCode == 304 {
                return false
            }

            // Store new ETag if present
            if let newETag = httpResponse.value(forHTTPHeaderField: "ETag") {
                UserDefaults.standard.set(newETag, forKey: etagKey)
            }

            return true
        } catch {
            // On error, try to fetch anyway
            return true
        }
    }

    private func fetchRemoteShifts() async throws -> RemoteShiftsResponse {
        let (data, response) = try await URLSession.shared.data(from: remoteURL)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ShiftServiceError.invalidResponse
        }

        // Store ETag for future requests
        if let etag = httpResponse.value(forHTTPHeaderField: "ETag") {
            UserDefaults.standard.set(etag, forKey: etagKey)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(RemoteShiftsResponse.self, from: data)
        } catch {
            throw ShiftServiceError.decodingError(underlying: error)
        }
    }

    private func updateLocalShifts(from response: RemoteShiftsResponse, modelContext: ModelContext) async throws {
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
}
