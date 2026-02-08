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
    @State private var startTime: Date
    @State private var duration: TimeInterval
    
    private var isEditing: Bool {
        shift != nil
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        duration > 0
    }
    
    init(shift: Shift? = nil, category: Category, location: Location) {
        self.shift = shift
        self.category = category
        self.location = location
        
        if let shift {
            _name = State(initialValue: shift.name)
            
            // Create a date from the start time (seconds since midnight)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            _startTime = State(initialValue: today.addingTimeInterval(shift.startTime))
            _duration = State(initialValue: shift.duration)
        } else {
            _name = State(initialValue: "")
            
            // Default to 8:00 AM
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            _startTime = State(initialValue: today.addingTimeInterval(8 * 3600))
            _duration = State(initialValue: 7.5 * 3600) // 7:30 hours
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Turno") {
                    TextField("Nombre del turno", text: $name)
                        .autocorrectionDisabled()
                }
                
                Section("Horario") {
                    DatePicker(
                        "Hora de inicio",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Duración",
                        selection: Binding(
                            get: {
                                let calendar = Calendar.current
                                let today = calendar.startOfDay(for: Date())
                                return today.addingTimeInterval(duration)
                            },
                            set: { newValue in
                                let calendar = Calendar.current
                                let midnight = calendar.startOfDay(for: newValue)
                                duration = newValue.timeIntervalSince(midnight)
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
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
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        saveShift()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
    private func saveShift() {
        // Calculate seconds since midnight for start time
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: startTime)
        let startTimeInterval = startTime.timeIntervalSince(midnight)
        
        if let existingShift = shift {
            existingShift.name = name.trimmingCharacters(in: .whitespaces)
            existingShift.startTime = startTimeInterval
            existingShift.duration = duration
            existingShift.isUserCreated = true
        } else {
            let newShift = Shift(
                name: name.trimmingCharacters(in: .whitespaces),
                startTime: startTimeInterval,
                duration: duration,
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
