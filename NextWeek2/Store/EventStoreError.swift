//
//  EventStoreError.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import Foundation

enum EventStoreError: Error {
    case denied
    case restricted
    case unknown
    case upgrade
}

extension EventStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .denied:
            return NSLocalizedString("La app no tiene permiso para acceder al Calendario en Ajustes.", comment: "Acceso denegado")
        case .restricted:
            return NSLocalizedString("Este dispositivo no permite el acceso al Calendario.", comment: "Acceso restringido")
        case .unknown:
            return NSLocalizedString("Se ha producido un error desconocido.", comment: "Error desconocido")
        case .upgrade:
            let access = "La app tiene acceso de solo escritura al Calendario en Ajustes."
            let update = "Por favor, concede acceso completo para que la app pueda obtener y eliminar tus eventos."
            return NSLocalizedString("\(access) \(update)", comment: "Actualiza a acceso completo")
        }
    }
}
