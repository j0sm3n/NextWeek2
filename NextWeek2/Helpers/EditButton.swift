//
//  EditButton.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import SwiftUI

struct EditButton: View {
    @Binding var editMode: EditMode
    var action: () -> Void = {}

    var body: some View {
        Button {
            withAnimation {
                if editMode == .active {
                    action()
                    editMode = .inactive
                } else {
                    editMode = .active
                }
            }
        } label: {
            if editMode == .active {
                Text("Hecho").bold()
            } else {
                Text("Editar")
            }
        }
    }
}

#Preview("Inactive", traits: .sizeThatFitsLayout) {
    EditButton(editMode: .constant(.inactive))
}
#Preview("Active", traits: .sizeThatFitsLayout) {
    EditButton(editMode: .constant(.active))
}
#Preview("Transient", traits: .sizeThatFitsLayout) {
    EditButton(editMode: .constant(.transient))
}
