//
//  ShiftsManagementView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 7/2/26.
//

import SwiftUI
import SwiftData

struct ShiftsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var shifts: [Shift]
    
    @State private var selectedCategory: Category = .maquinista
    @State private var selectedLocation: Location = .benidorm
    @State private var showingAddSheet = false
    @State private var shiftToEdit: Shift?
    
    private var filteredShifts: [Shift] {
        let categoryFiltered = shifts.filter {
            $0.category == selectedCategory.rawValue &&
            $0.residence == selectedLocation.rawValue
        }
        return categoryFiltered.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if filteredShifts.isEmpty {
                    emptyStateView
                } else {
                    shiftsListView
                }
            }
            .navigationTitle("Gestión de Turnos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarTitleMenu { filterSection }
            .navigationSubtitle("\(selectedCategory.rawValue) \(selectedLocation.rawValue)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Añadir Turno", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ShiftEditView(
                    category: selectedCategory,
                    location: selectedLocation
                )
            }
            .sheet(item: $shiftToEdit) { shift in
                ShiftEditView(
                    shift: shift,
                    category: selectedCategory,
                    location: selectedLocation
                )
            }
        }
    }
    
    private var filterSection: some View {
        Group {
            Section("Categoría") {
                ForEach(Category.allCases, id: \.self) { category in
                    Button {
                        withAnimation {
                            selectedCategory = category
                        }
                    } label: {
                        if selectedCategory == category {
                            Label(category.rawValue, systemImage: "checkmark")
                        } else {
                            Text(category.rawValue)
                        }
                    }
                }
            }

            Section("Residencia") {
                ForEach(Location.allCases, id: \.self) { location in
                    Button {
                        withAnimation {
                            selectedLocation = location
                        }
                    } label: {
                        if selectedLocation == location {
                            Label(location.rawValue, systemImage: "checkmark")
                        } else {
                            Text(location.rawValue)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No hay turnos", systemImage: "calendar.badge.clock")
        } description: {
            Text("No se encontraron turnos para esta categoría y ubicación.")
        } actions: {
            Button {
                showingAddSheet = true
            } label: {
                Text("Añadir Turno")
            }
            .buttonStyle(GlassProminentButtonStyle())
        }
    }
    
    private var shiftsListView: some View {
        List {
            ForEach(filteredShifts) { shift in
                ShiftRowView(shift: shift)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        shiftToEdit = shift
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteShift(shift)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            shiftToEdit = shift
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func deleteShift(_ shift: Shift) {
        withAnimation {
            modelContext.delete(shift)
            do {
                try modelContext.save()
            } catch {
                print("Error deleting shift: \(error.localizedDescription)")
            }
        }
    }
}

struct ShiftRowView: View {
    let shift: Shift
    
    var body: some View {
        HStack(spacing: 12) {
            // Shift Name
            VStack(alignment: .leading, spacing: 4) {
                Text(shift.name)
                    .font(.headline)
                
                if shift.isUserCreated {
                    Label("Creado por usuario", systemImage: "person.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Time Info
            VStack(alignment: .trailing, spacing: 4) {
                Label(shift.startTime.formattedAsTime, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Label(shift.duration.formattedAsDuration, systemImage: "hourglass")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ShiftsManagementView()
        .modelContainer(for: Shift.self, inMemory: true)
}
