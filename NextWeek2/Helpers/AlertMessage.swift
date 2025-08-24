//
//  AlertMessage.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 2/5/25.
//

import SwiftUI

struct AlertMessage: ViewModifier {
    var title: String?
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(
                title ?? "Ha ocurrido un error",
                isPresented: $isPresented,
                actions: { }
            )
    }
}

extension View {
    func alertMessage(title: String?, isPresented: Binding<Bool>) -> some View {
        modifier(AlertMessage(title: title, isPresented: isPresented))
    }
}
