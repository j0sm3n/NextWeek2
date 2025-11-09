//
//  Shift.swift
//  NextWeek
//
//  Created by Jose Antonio Mendoza on 4/4/24.
//

import Foundation

struct Shift {
    let name: String
    let startTime: TimeInterval?
    let duration: TimeInterval?
    
    init(name: String, startTime: TimeInterval? = nil, duration: TimeInterval? = nil) {
        self.name = name
        self.startTime = startTime
        self.duration = duration
    }
}

extension Shift {
    static func shiftsFor(category: Category) -> [Shift] {
        switch category {
        case .maquinista:
            maquinistaShifts
        case .usi:
            usiShifts
        }
    }

    static let maquinistaShifts: [Shift] = [
        // Benidorm
        // - conduccion
        Shift(name: "1", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 20)),
        Shift(name: "2", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 24)),
        Shift(name: "3", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 19)),
        Shift(name: "4", startTime: TimeInterval(hour: 9, minute: 20), duration: TimeInterval(hour: 8, minute: 19)),
        Shift(name: "5", startTime: TimeInterval(hour: 14, minute: 20), duration: TimeInterval(hour: 8, minute: 19)),
        Shift(name: "6", startTime: TimeInterval(hour: 17, minute: 9), duration: TimeInterval(hour: 6, minute: 20)),
        Shift(name: "7", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 8, minute: 19)),
        // - reserva
        Shift(name: "8", startTime: TimeInterval(hour: 5, minute: 10), duration: TimeInterval(hour: 8, minute: 35)),
        Shift(name: "9", startTime: TimeInterval(hour: 14, minute: 10), duration: TimeInterval(hour: 8)),
        // - incidencia
        Shift(name: "CI1", startTime: TimeInterval(hour: 6, minute: 30), duration: TimeInterval(hour: 7, minute: 46)),
        Shift(name: "CI2", startTime: TimeInterval(hour: 15, minute: 30), duration: TimeInterval(hour: 7, minute: 46)),
        // - cursillo
        Shift(name: "CU1", startTime: TimeInterval(hour: 7, minute: 30), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "CUM", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "CU2", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 30)),
        
        // Denia
        Shift(name: "21", startTime: TimeInterval(hour: 5, minute: 32), duration: TimeInterval(hour: 7, minute: 39)),
        Shift(name: "22", startTime: TimeInterval(hour: 9, minute: 47), duration: TimeInterval(hour: 8, minute: 24)),
        Shift(name: "23", startTime: TimeInterval(hour: 14, minute: 47), duration: TimeInterval(hour: 8, minute: 24)),
        Shift(name: "24", startTime: TimeInterval(hour: 5, minute: 35), duration: TimeInterval(hour: 7, minute: 35)),
        Shift(name: "25", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 35)),
        Shift(name: "SP1", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 43)),
        Shift(name: "SP2", startTime: TimeInterval(hour: 14, minute: 15), duration: TimeInterval(hour: 7, minute: 43)),
    ]
    
    static let usiShifts: [Shift] = [
        // Turno 1
        Shift(name: "1A", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "1B", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "1C", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "1D", startTime: TimeInterval(hour: 7, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        // Turno 2
        Shift(name: "2A", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "2B", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "2C", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "2D", startTime: TimeInterval(hour: 7, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        // Turno 3
        Shift(name: "3A", startTime: TimeInterval(hour: 8, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "3B", startTime: TimeInterval(hour: 11, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "3C", startTime: TimeInterval(hour: 7, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "3D", startTime: TimeInterval(hour: 10, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        // Turno 4
        Shift(name: "4A", startTime: TimeInterval(hour: 8, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "4B", startTime: TimeInterval(hour: 11, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "4C", startTime: TimeInterval(hour: 7, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "4D", startTime: TimeInterval(hour: 10, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        // Turno 5
        Shift(name: "5A", startTime: TimeInterval(hour: 16, minute: 10), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "5B", startTime: TimeInterval(hour: 16, minute: 10), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "5C", startTime: TimeInterval(hour: 13, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "5D", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        // Turno 6
        Shift(name: "6A", startTime: TimeInterval(hour: 16, minute: 10), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "6B", startTime: TimeInterval(hour: 16, minute: 10), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "6C", startTime: TimeInterval(hour: 13, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "6D", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 7, minute: 30)),
        // - cursillo
        Shift(name: "CU1", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 30)),
        Shift(name: "CU2", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 30)),

    ]
}
