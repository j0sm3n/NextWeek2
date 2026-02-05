# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NextWeek2 is a native iOS app (Swift/SwiftUI) for managing work schedules and shifts. Users can import PDF/XLSX schedule files, preview parsed shifts, and save them to system calendars. The app supports multiple agents (employees) with individual calendar assignments.

- **Platform**: iOS 18.4+
- **Language**: Swift 6
- **Framework**: SwiftUI + EventKit
- **Localization**: Spanish (es)

## Build Commands

```bash
# Open in Xcode
open NextWeek2.xcodeproj

# Build for simulator
xcodebuild -project NextWeek2.xcodeproj -scheme "NextWeek2" -destination "platform=iphonesimulator,id=188C34AD-4857-466D-B827-C3CC1FA8F6E5" -derivedDataPath DerivedData -configuration Debug build 2>&1 | xcsift -w
```

## Dependencies

- **CoreXLSX** (Swift Package): Excel file parsing
- **EventKit** (system): Calendar access
- **PDFKit** (system): PDF text extraction

## Architecture

```
NextWeek2/
├── App/           - Entry point, environment setup
├── Models/        - Data models (Event, Shift, Agent, Category, Location)
├── Store/         - State management & data persistence
├── Views/         - SwiftUI components (Event, Import, Settings views)
├── Extensions/    - Date, TimeInterval, EKEvent, Array, String, URL helpers
└── Helpers/       - File parsing, error types, UI utilities
```

### State Management

- **EventStoreManager** (`@MainActor @Observable`): Calendar state, passed via `.environment()`
- **EventDataStore** (`actor`): Isolated EventKit operations, prevents race conditions
- **AgentStore** (`@Observable`): Agent/calendar configuration, persisted to UserDefaults

### Data Flow

1. User requests calendar authorization (full access required)
2. User assigns system calendars to agents in Settings
3. User imports PDF/XLSX via FileImporter
4. AppFileManager parses file, extracts schedules per agent
5. ImportView shows 7-day preview before saving
6. Events saved to assigned agent calendars via EventKit
7. EventList displays all agent events grouped by date

### Key Models

- **Agent**: `cf` (ID), `name`, `category` (Maquinista/USI), `location` (Benidorm/Denia), `calendar`
- **Shift**: Predefined patterns with `startTime` and `duration` per category
- **Event**: Shift instance on a specific date
- **AgentCalendar**: Links agent to system calendar via `calendarIdentifier`

### Shift Categories

- **Maquinista**: ~20 shifts (1-9, 21-25, CI1-2, CU1-2, SP1-2)
- **USI**: ~26 shifts in turn groups (1A-1D through 6A-6D, CU1-2)

## Code Patterns

- Modern Swift concurrency: `async/await`, `@MainActor`, `actor` isolation
- Custom error enums with `LocalizedError` (Spanish messages)
- Security-scoped resource access for file picker
- EKEventStoreChanged notifications for calendar sync
- NavigationStack for navigation, `@Environment` for DI

## Git Conventions

- Commit titles and descriptions must be in English
