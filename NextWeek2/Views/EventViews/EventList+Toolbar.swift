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
        ToolbarItem(placement: .topBarTrailing) {
            EditButton(editMode: $editMode) {
                selection.removeAll()
                editMode = .inactive
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            if editMode == .active {
                Button {
                    removeEvents(Array(selection))
                } label: {
                    Text("Borrar")
                }
                .tint(.red)
                .disabled(selection.isEmpty)
            }
        }
        
        ToolbarItem(placement: .bottomBar) {
            Button("Añadir turnos") {
                showFileChooser = true
            }
            .buttonStyle(.myAppPrimaryButton)
        }
    }
}
