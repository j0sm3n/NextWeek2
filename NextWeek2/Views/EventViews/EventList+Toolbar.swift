//
//  EventList+Toolbar.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import SwiftUI

extension EventList {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Añadir turnos", systemImage: "plus") {
                showFileChooser = true
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button("Ajustes", systemImage: "gear") {
                showSettings = true
            }
        }
    }
}
