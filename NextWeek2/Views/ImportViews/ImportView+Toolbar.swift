//
//  ImportView+Toolbar.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 5/5/25.
//

import SwiftUI

extension ImportView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
                Task {
                    do {
                        try await insertEvents()
                        dismiss()
                    } catch {
                        showAlert(title: "Ha ocurrido un error al guardar los turnos.")
                    }
                }
            }
        }
    }
}
