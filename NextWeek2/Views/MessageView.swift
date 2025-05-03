//
//  MessageView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

enum Message: Hashable, Identifiable {
    var id: Self { return self }
    
    case none
    case events
    case denied
    case restricted
    case upgrade
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .none:
            return ""
        case .events:
            return "No hay eventos."
        case .denied:
            return "La aplicación no tiene permiso para acceder a los eventos del calendario. Por favor, concede acceso a la aplicación al Calendario en Ajustes."
        case .restricted:
            return "Este dispositivo no permite el acceso a los eventos del calendario. Por favor, actualiza los permisos en Ajustes."
        case .upgrade:
            let access = "La aplicación tiene acceso de solo escritura al Calendario en Ajustes."
            let update = "Por favor, concede acceso completo para que la aplicación pueda obtener y eliminar tus eventos."
            return "\(access) \(update)"
        }
    }
}

struct MessageView: View {
    var message: Message
    
    init(message: Message) {
        self.message = message
    }
    
    var body: some View {
        ContentUnavailableView(
            "",
            systemImage: "exclamationmark.triangle.fill",
            description: Text(message.localizedName)
        )
    }
}

#Preview("None") {
    MessageView(message: .none)
}
#Preview("Events") {
    MessageView(message: .events)
}
#Preview("Denied") {
    MessageView(message: .denied)
}
#Preview("Restricted") {
    MessageView(message: .restricted)
}
#Preview("Upgrade") {
    MessageView(message: .upgrade)
}
