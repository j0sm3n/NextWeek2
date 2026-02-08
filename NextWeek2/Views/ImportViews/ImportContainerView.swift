//
//  ImportContainerView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 7/2/26.
//

import SwiftUI

struct ImportContainerView: View {
    @State private var showingFilePicker = false
    @State private var selectedFile: URL?
    
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Importar Horario", systemImage: "calendar.badge.plus")
            } description: {
                Text("Selecciona un archivo PDF o Excel con los horarios de la semana")
            } actions: {
                Button {
                    showingFilePicker = true
                } label: {
                    Text("Seleccionar Archivo")
                }
                .buttonStyle(.glassProminent)
            }
            .navigationTitle("Importar Turnos")
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.pdf, .spreadsheet],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let files):
                    if let file = files.first, file.startAccessingSecurityScopedResource() {
                        selectedFile = file
                    }
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
            .sheet(item: $selectedFile) {
                selectedFile?.stopAccessingSecurityScopedResource()
            } content: { file in
                ImportView(filename: file)
            }
        }
    }
}

#Preview {
    ImportContainerView()
        .environment(EventStoreManager())
        .environment(AgentStore())
}
