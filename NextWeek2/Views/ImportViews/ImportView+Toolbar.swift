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
            Button("Cancelar") {
                dismiss()
            }
        }
    }
}
