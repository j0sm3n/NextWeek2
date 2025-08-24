//
//  AlertError.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

struct AlertError: ViewModifier {
    var message: String?
    var title: String?
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(
                title == message ? "Ha ocurrido un error" : title ?? "Ha ocurrido un error",
                isPresented: $isPresented,
                actions: { },
                message: { Text(message ?? "Ha ocurrido un error.") }
            )
    }
}

extension View {
    func alertErrorMessage(message: String?, title: String?, isPresented: Binding<Bool>) -> some View {
        modifier(AlertError(message: message, title: title, isPresented: isPresented))
    }
}
