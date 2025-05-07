//
//  FileManager.swift
//  NextWeek
//
//  Created by Jose Antonio Mendoza on 11/3/23.
//

import CoreXLSX
import Foundation
import PDFKit

class FileManager {
    let fileURL: URL
    let agent: Agent
    let shifts: [Shift]
    
    var schedule: Schedule?
    
    init(fileURL: URL, agent: Agent, shifts: [Shift]) {
        self.fileURL = fileURL
        self.agent = agent
        self.shifts = shifts
    }
    
    func getData() {
        if fileURL.pathExtension == "xlsx" {
            getAgentsWeekFromXLSX()
        } else if fileURL.pathExtension == "pdf" {
            getAgentsWeekFromPDF()
        }
    }
    
    // MARK: - PDF functions
    private func getAgentsWeekFromPDF() {
        guard let pdfDocument = PDFDocument(url: fileURL) else {
            fatalError("Couldn't open PDF document at \(fileURL)")
        }
        
        var fullText: String = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string {
                fullText += pageText
            }
        }
        
        if let rowShifts = getAgentRow(of: agent, from: fullText) {
            let monday = getDate(from: fullText)
            var week: [WorkDay] = []
            
            for i in 0...6 {
                let calendarEvent = WorkDay(
                    shift: shifts.filter({ $0.name == rowShifts[i] }).first ?? Shift(name: rowShifts[i]),
                    date: Calendar.current.date(byAdding: .day, value: i, to: monday) ?? Date()
                )
                week.append(calendarEvent)
            }
            
            schedule = Schedule(agentCF: agent.cf, week: week)
        }
    }
    
    private func getDate(from text: String) -> Date {
        guard let startDateString = extractLine(startingWith: "DÍA INÍCIO", from: text) else {
            fatalError("Couldn't get start date in text")
        }
        if let startDate = startDateString.components(separatedBy: " ").last {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yy"
            formatter.locale = Locale(identifier: "es_ES")
            formatter.timeZone = TimeZone.current
            
            if let date = formatter.date(from: startDate) {
                return date
            } else {
                fatalError("Coludn't parse date \(startDate)")
            }
        }
        return .now
    }
    
    private func getAgentRow(of agent: Agent, from text: String) -> [String]? {
        if let agentRow = extractLine(startingWith: String(agent.cf), from: text) {
            let agentRowComponents = agentRow.components(separatedBy: " ")
            let rowShifts = Array(agentRowComponents.suffix(7))
            guard rowShifts.count == 7 else { return nil }
            return rowShifts
        }
        return nil
    }
    
    private func extractLine(startingWith prefix: String, from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix(prefix) {
                return line
            }
        }
        
        return nil
    }
    
    // MARK: - XLSX functions
    private func getAgentsWeekFromXLSX() {
        let file = getXLSXFile()
        let monday = getDate(from: file)
        
        guard let row = getAgentRow(of: agent, from: file) else { return }
        
        var week: [WorkDay] = []
        let rowShifts = Array(row[2...])
        
        for i in 0...6 {
            let shift = shifts.filter { $0.name == rowShifts[i] }.first
            let calendarEvent = WorkDay(
                shift: shift ?? Shift(name: rowShifts[i]),
                date: Calendar.current.date(byAdding: .day, value: i, to: monday) ?? Date()
            )
            week.append(calendarEvent)
        }
        
        schedule = Schedule(agentCF: agent.cf, week: week)
    }
    
    private func getXLSXFile() -> XLSXFile {
        guard let file = XLSXFile(filepath: fileURL.relativePath) else {
            fatalError("XLSX file at \(fileURL) is corrupted or does not exist")
        }
        return file
    }
    
    private func getWorksheet(from file: XLSXFile, sheetName: SheetName) throws -> Worksheet? {
        do {
            let workbook = try file.parseWorkbooks()
            for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook.first!) {
                guard name == sheetName.rawValue else { continue }
                let worksheet = try file.parseWorksheet(at: path)
                return worksheet
            }
        } catch {
            print("❌ Error: \(error)")
        }
        return nil
    }
    
    private func getDate(from file: XLSXFile) -> Date {
        guard let worksheet = try? getWorksheet(from: file, sheetName: .fecha) else {
            return .now
        }
        let columnCDates = worksheet.cells(atColumns: [ColumnReference("C")!])
            .compactMap { $0.dateValue }
        return columnCDates.first ?? .now
    }
    
    private func getAgentRow(of agent: Agent, from file: XLSXFile) -> [String]? {
        var sheet: SheetName
        
        switch (agent.category, agent.location) {
        case (.maquinista, .benidorm):
            sheet = .maquinistaBenidorm
        case (.usi, .benidorm):
            sheet = .usiBenidorm
        default:
            // TODO: Change fatalError to a notification
            fatalError("This category or location is not implemented yet.")
        }
        
        guard let worksheet = try? getWorksheet(from: file, sheetName: sheet) else {
            print("No se ha encontrado nada de nada")
            return nil
        }
        
        do {
            if let sharedStrings = try file.parseSharedStrings() {
                let rows = worksheet.data?.rows.filter { row in
                    if !row.cells.isEmpty,
                       let firstCellValue = row.cells.first?.stringValue(sharedStrings),
                       firstCellValue.contains(String(agent.cf)) {
                        return firstCellValue.isNumeric
                    }
                    return false
                }
                
                guard rows?.count == 1 else {
                    print("Hay más de una fila que cumple con agente = \(agent.cf)")
                    return nil
                }
                
                let cells = rows![0].cells.filter { $0.value?.isEmpty == false }
                var cellsValues: [String] = []
                let cellsSharedStrings = cells.compactMap { $0.stringValue(sharedStrings)}
                cellsSharedStrings.forEach { cell in
                    if cell.isNumeric {
                        cellsValues.append(String(Int(Double(cell)!)))
                    } else {
                        cellsValues.append(cell)
                    }
                }
                return cellsValues
            }
            return nil
        } catch {
            print("❌ Error: \(error)")
            return nil
        }
    }
}

