//
//  FileManagerError.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 23/5/25.
//

import Foundation

enum FileManagerError: Error {
    case cantOpenFile
    case cantGetAgentRow
    case agentNotFound
    case noShiftsAvailable
    case corruptedXLSXFile
    case cantParseDate
    case categoryNotImplemented
}

extension FileManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cantOpenFile:
            return NSLocalizedString("El archivo PDF no se ha podido abrir.", comment: "Error al abrir el archivo")
        case .cantGetAgentRow:
            return NSLocalizedString("No se ha podido extraer la fila del agente.", comment: "Agente no encontrado")
        case .agentNotFound:
            return NSLocalizedString("No se ha encontrado los turnos del agente seleccionado.", comment: "Agente no encontrado")
        case .noShiftsAvailable:
            return NSLocalizedString("No hay datos de turnos disponibles. Verifica tu conexión a internet.", comment: "Sin datos de turnos")
        case .corruptedXLSXFile:
            return NSLocalizedString("El archivo Excel está corrupto o no se puede leer. Por favor, verifica que el archivo sea válido.", comment: "Archivo corrupto")
        case .cantParseDate:
            return NSLocalizedString("No se ha podido leer la fecha del archivo.", comment: "Error al leer fecha")
        case .categoryNotImplemented:
            return NSLocalizedString("Esta combinación de categoría y ubicación no está implementada aún.", comment: "Categoría no implementada")
        }
    }
}
