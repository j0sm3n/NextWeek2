//
//  ShiftEditView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 7/2/26.
//

import SwiftUI
import SwiftData

struct ShiftEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let shift: Shift?
    let category: Category
    let location: Location
    
    @State private var name: String
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var durationHours: Int
    @State private var durationMinutes: Int
    
    private var isEditing: Bool {
        shift != nil
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (durationHours > 0 || durationMinutes > 0)
    }
    
    init(shift: Shift? = nil, category: Category, location: Location) {
        self.shift = shift
        self.category = category
        self.location = location
        
        if let shift = shift {
            _name = State(initialValue: shift.name)
            
            let startSeconds = Int(shift.startTime)
            _startHour = State(initialValue: startSeconds / 3600)
            _startMinute = State(initialValue: (startSeconds % 3600) / 60)
            
            let durationSeconds = Int(shift.duration)
            _durationHours = State(initialValue: durationSeconds / 3600)
            _durationMinutes = State(initialValue: (durationSeconds % 3600) / 60)
        } else {
            _name = State(initialValue: "")
            _startHour = State(initialValue: 8)
            _startMinute = State(initialValue: 0)
            _durationHours = State(initialValue: 8)
            _durationMinutes = State(initialValue: 0)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Turno") {
                    TextField("Nombre del turno", text: $name)
                        .autocorrectionDisabled()
                }
                
                Section("Hora de Inicio") {
                    Picker("Hora", selection: $startHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    
                    Picker("Minutos", selection: $startMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                }
                
                Section("Duración") {
                    Picker("Horas", selection: $durationHours) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour)h").tag(hour)
                        }
                    }
                    
                    Picker("Minutos", selection: $durationMinutes) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text("\(minute)m").tag(minute)
                        }
                    }
                }
                
                Section {
                    LabeledContent("Categoría", value: category.rawValue)
                    LabeledContent("Ubicación", value: location.rawValue)
                }
                
                if isEditing && shift?.isUserCreated == false {
                    Section {
                        Text("Este turno proviene de datos remotos. Al editarlo, se marcará como creado por usuario y no se sobrescribirá con actualizaciones remotas.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(isEditing ? "Editar Turno" : "Nuevo Turno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveShift()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveShift() {
        let startTimeInterval = Double(startHour * 3600 + startMinute * 60)
        let durationInterval = Double(durationHours * 3600 + durationMinutes * 60)
        
        if let existingShift = shift {
            existingShift.name = name.trimmingCharacters(in: .whitespaces)
            existingShift.startTime = startTimeInterval
            existingShift.duration = durationInterval
            existingShift.isUserCreated = true
        } else {
            let newShift = Shift(
                name: name.trimmingCharacters(in: .whitespaces),
                startTime: startTimeInterval,
                duration: durationInterval,
                category: category.rawValue,
                residence: location.rawValue,
                isUserCreated: true
            )
            modelContext.insert(newShift)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview("New Shift") {
    ShiftEditView(category: .maquinista, location: .benidorm)
        .modelContainer(for: Shift.self, inMemory: true)
}

#Preview("Edit Shift") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Shift.self, configurations: config)
    let shift = Shift(
        name: "Turno 1",
        startTime: 28800,
        duration: 28800,
        category: "Maquinista",
        residence: "Benidorm",
        isUserCreated: false
    )
    container.mainContext.insert(shift)
    
    return ShiftEditView(shift: shift, category: .maquinista, location: .benidorm)
        .modelContainer(container)
}
