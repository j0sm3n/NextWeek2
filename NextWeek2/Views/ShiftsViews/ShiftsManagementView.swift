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
    @State private var searchText = ""
    
    private var filteredShifts: [Shift] {
        let categoryFiltered = shifts.filter {
            $0.category == selectedCategory.rawValue &&
            $0.residence == selectedLocation.rawValue
        }
        
        if searchText.isEmpty {
            return categoryFiltered.sorted { $0.name < $1.name }
        } else {
            return categoryFiltered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Section with Liquid Glass
                filterSection
                
                // Shifts List
                if filteredShifts.isEmpty {
                    emptyStateView
                } else {
                    shiftsListView
                }
            }
            .navigationTitle("Gestión de Turnos")
            .searchable(text: $searchText, prompt: "Buscar turno")
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
        GlassEffectContainer(spacing: 12) {
            VStack(spacing: 12) {
                // Category Picker
                HStack(spacing: 12) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Button {
                            withAnimation(.smooth) {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(GlassButtonStyle())
                        .opacity(selectedCategory == category ? 1.0 : 0.6)
                    }
                }
                .glassEffect()
                
                // Location Picker
                HStack(spacing: 12) {
                    ForEach(Location.allCases, id: \.self) { location in
                        Button {
                            withAnimation(.smooth) {
                                selectedLocation = location
                            }
                        } label: {
                            Text(location.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(GlassButtonStyle())
                        .opacity(selectedLocation == location ? 1.0 : 0.6)
                    }
                }
                .glassEffect()
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
            try? modelContext.save()
        }
    }
}

struct ShiftRowView: View {
    let shift: Shift
    
    private var startTimeFormatted: String {
        let hours = Int(shift.startTime) / 3600
        let minutes = (Int(shift.startTime) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    private var durationFormatted: String {
        let hours = Int(shift.duration) / 3600
        let minutes = (Int(shift.duration) % 3600) / 60
        
        if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
    
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
                Label(startTimeFormatted, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Label(durationFormatted, systemImage: "hourglass")
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
