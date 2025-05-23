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
        }
    }
}
