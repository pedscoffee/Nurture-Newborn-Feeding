# Nurture iOS App — Development Plan

> **Version:** 1.0  
> **Last Updated:** November 2025  
> **Project Type:** Native iOS App (Swift/SwiftUI)  
> **Target Platform:** iOS 17+, Universal (iPhone & iPad)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Overview](#2-product-overview)
3. [Technical Architecture](#3-technical-architecture)
4. [Data Models](#4-data-models)
5. [Feature Specifications](#5-feature-specifications)
6. [User Interface Design](#6-user-interface-design)
7. [CloudKit & Sync Architecture](#7-cloudkit--sync-architecture)
8. [Live Activities & Notifications](#8-live-activities--notifications)
9. [In-App Purchase Implementation](#9-in-app-purchase-implementation)
10. [Development Phases](#10-development-phases)
11. [File & Project Structure](#11-file--project-structure)
12. [Testing Strategy](#12-testing-strategy)
13. [App Store Preparation](#13-app-store-preparation)
14. [Future Roadmap](#14-future-roadmap)
15. [Technical Decisions Log](#15-technical-decisions-log)
16. [Resources & References](#16-resources--references)

---

## 1. Executive Summary

### Project Goal

Transform the existing Nurture PWA into a native iOS application that provides a calming, reliable newborn feeding and diaper tracking experience with real-time countdowns, Lock Screen presence via Live Activities, and optional family sharing via CloudKit sync.

### Key Value Propositions

- **Reliability:** Native notifications and background processing ensure parents never miss a feeding window
- **Visibility:** Live Activities display countdown timers on Lock Screen and Dynamic Island without opening the app
- **Collaboration:** Family Sync allows both parents to track from their own devices in real-time
- **Simplicity:** Calm, minimal UI designed for exhausted parents at 3am

### Business Model

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | Full local functionality, single device |
| **Family Sync** | $0.99 (one-time) | CloudKit sync, multi-device, sharing with partner |

### Technical Stack

| Component | Technology |
|-----------|------------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Local Storage | SwiftData |
| Cloud Sync | CloudKit (Private Database) |
| Notifications | UNUserNotificationCenter |
| Live Activities | ActivityKit |
| Purchases | StoreKit 2 |
| Minimum iOS | 17.0 |

---

## 2. Product Overview

### Core Functionality

#### Feeding Tracking
- Log feeds with one tap (starts timer automatically)
- Track feed type: Left breast, Right breast, Both, Bottle, Formula
- Optional duration tracking (minutes)
- Optional amount tracking (ml/oz)
- Formula brand/type field for formula feeds
- Notes field for any feed
- Edit historical entries

#### Diaper Tracking
- Quick-log buttons: Wet, Dirty, Both
- Timestamp and notes for each entry
- 24-hour statistics

#### Timer System
- **Countdown Mode:** Time remaining until next scheduled feed
- **Stopwatch Mode:** Time elapsed since last feed
- Configurable feeding intervals (2, 2.5, 3, 4 hours)
- Visual and audio alerts when feed is due

#### History & Statistics
- Chronological list of all events
- 24-hour feed count
- 24-hour diaper counts (wet/dirty)
- Average feeding interval calculation
- Data export (JSON)

#### Family Sync (Paid Feature)
- Real-time sync between devices via CloudKit
- Share tracking space with partner via invite code/link
- All family members see the same data
- Offline-first with automatic sync on reconnection

### User Personas

**Primary:** New parents (0-6 months postpartum) tracking feeding schedules and diaper output to ensure baby is eating enough and producing adequate wet/dirty diapers.

**Usage Context:** Frequently used while sleep-deprived, in low-light conditions, often one-handed while holding baby.

---

## 3. Technical Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Nurture App                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    UI Layer (SwiftUI)                     │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │  │
│  │  │  HomeView   │ │ HistoryView │ │    SettingsView     │ │  │
│  │  │  - Timer    │ │ - EventList │ │ - Preferences       │ │  │
│  │  │  - Actions  │ │ - Stats     │ │ - Family Sync       │ │  │
│  │  │  - Preview  │ │ - Export    │ │ - Purchase          │ │  │
│  │  └─────────────┘ └─────────────┘ └─────────────────────┘ │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │  │
│  │  │ EditSheet   │ │OnboardingVw │ │   BabyProfileView   │ │  │
│  │  └─────────────┘ └─────────────┘ └─────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Manager Layer                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │              NurtureManager (Observable)            │  │  │
│  │  │  - Current baby selection                           │  │  │
│  │  │  - Timer state (countdown/stopwatch values)         │  │  │
│  │  │  - Computed stats                                   │  │  │
│  │  │  - Coordinates all services                         │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Service Layer                           │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐  │  │
│  │  │ TimerService │ │NotificationSv│ │   AudioService   │  │  │
│  │  │ - Countdown  │ │ - Schedule   │ │ - Chime synth    │  │  │
│  │  │ - Background │ │ - Permissions│ │ - Playback       │  │  │
│  │  └──────────────┘ └──────────────┘ └──────────────────┘  │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐  │  │
│  │  │  SyncEngine  │ │PurchaseManager│ │LiveActivitySvc  │  │  │
│  │  │ - CloudKit   │ │ - StoreKit 2 │ │ - Start/Update   │  │  │
│  │  │ - Conflicts  │ │ - Restore    │ │ - End            │  │  │
│  │  └──────────────┘ └──────────────┘ └──────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Data Layer                             │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │                 SwiftData Store                     │  │  │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────┐ │  │  │
│  │  │  │FeedEvent │ │DiaperEvnt│ │  Baby    │ │Settings│ │  │  │
│  │  │  └──────────┘ └──────────┘ └──────────┘ └───────┘ │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                          │                                │  │
│  │                          ▼ (if sync enabled)              │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │              CloudKit Private Database              │  │  │
│  │  │  - CKRecord mapping                                 │  │  │
│  │  │  - CKShare for family sharing                       │  │  │
│  │  │  - Subscription for real-time updates               │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    App Extensions                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Live Activity Extension                      │   │
│  │  - Lock Screen UI                                         │   │
│  │  - Dynamic Island (compact/expanded/minimal)              │   │
│  │  - Timer display synced with app state                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Widget Extension (Future)                    │   │
│  │  - Home screen widgets                                    │   │
│  │  - Stats at a glance                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action (e.g., "Start Feed")
        │
        ▼
    HomeView
        │
        ▼
  NurtureManager.logFeed()
        │
        ├──▶ SwiftData: Insert FeedEvent
        │
        ├──▶ TimerService: Reset countdown
        │
        ├──▶ NotificationService: Reschedule alert
        │
        ├──▶ LiveActivityService: Update Live Activity
        │
        └──▶ SyncEngine: Queue for CloudKit sync (if enabled)
```

---

## 4. Data Models

### Core Models (SwiftData)

```swift
import SwiftData
import Foundation

// MARK: - Baby Profile

@Model
final class Baby {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date?
    var feedIntervalMinutes: Int
    var createdAt: Date
    var modifiedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \FeedEvent.baby)
    var feedEvents: [FeedEvent] = []
    
    @Relationship(deleteRule: .cascade, inverse: \DiaperEvent.baby)
    var diaperEvents: [DiaperEvent] = []
    
    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var cloudKitShareID: String?
    
    init(name: String, feedIntervalMinutes: Int = 150) {
        self.id = UUID()
        self.name = name
        self.feedIntervalMinutes = feedIntervalMinutes
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

// MARK: - Feed Event

@Model
final class FeedEvent {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var type: FeedType
    var durationMinutes: Int?
    var amountML: Int?
    var formulaType: String?
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date
    var createdByDeviceID: String?
    
    // Relationship
    var baby: Baby?
    
    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var needsSync: Bool = false
    
    init(
        timestamp: Date = Date(),
        type: FeedType,
        baby: Baby?,
        durationMinutes: Int? = nil,
        amountML: Int? = nil,
        formulaType: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.type = type
        self.baby = baby
        self.durationMinutes = durationMinutes
        self.amountML = amountML
        self.formulaType = formulaType
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.createdByDeviceID = UIDevice.current.identifierForVendor?.uuidString
    }
}

// MARK: - Diaper Event

@Model
final class DiaperEvent {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var type: DiaperType
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date
    var createdByDeviceID: String?
    
    // Relationship
    var baby: Baby?
    
    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var needsSync: Bool = false
    
    init(
        timestamp: Date = Date(),
        type: DiaperType,
        baby: Baby?,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.type = type
        self.baby = baby
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.createdByDeviceID = UIDevice.current.identifierForVendor?.uuidString
    }
}

// MARK: - User Settings

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var theme: AppTheme
    var alarmSound: AlarmSound
    var defaultFeedType: FeedType
    var defaultFormulaType: String?
    var viewMode: TimerViewMode
    var hasUnlockedSync: Bool
    var hasCompletedOnboarding: Bool
    var selectedBabyID: UUID?
    
    init() {
        self.id = UUID()
        self.theme = .dark
        self.alarmSound = .softChime
        self.defaultFeedType = .both
        self.defaultFormulaType = nil
        self.viewMode = .countdown
        self.hasUnlockedSync = false
        self.hasCompletedOnboarding = false
        self.selectedBabyID = nil
    }
}

// MARK: - Enums

enum FeedType: String, Codable, CaseIterable {
    case left = "Left"
    case right = "Right"
    case both = "Both"
    case bottle = "Bottle"
    case formula = "Formula"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .left, .right, .both: return "🤱"
        case .bottle: return "🍼"
        case .formula: return "🍼"
        }
    }
}

enum DiaperType: String, Codable, CaseIterable {
    case wet = "Wet"
    case dirty = "Dirty"
    case both = "Both"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .wet: return "💧"
        case .dirty: return "💩"
        case .both: return "💧💩"
        }
    }
}

enum AppTheme: String, Codable, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"
}

enum AlarmSound: String, Codable, CaseIterable {
    case softChime = "Soft Chime"
    case gentleBell = "Gentle Bell"
    case harp = "Harp"
    case silent = "Silent"
    
    var fileName: String? {
        switch self {
        case .softChime: return "chime1"
        case .gentleBell: return "chime2"
        case .harp: return "chime3"
        case .silent: return nil
        }
    }
}

enum TimerViewMode: String, Codable {
    case countdown = "Countdown"
    case stopwatch = "Stopwatch"
}
```

### CloudKit Record Mapping

| SwiftData Model | CloudKit Record Type | Notes |
|-----------------|---------------------|-------|
| `Baby` | `CD_Baby` | Root record, shared via CKShare |
| `FeedEvent` | `CD_FeedEvent` | Parent reference to Baby |
| `DiaperEvent` | `CD_DiaperEvent` | Parent reference to Baby |

---

## 5. Feature Specifications

### 5.1 Timer System

#### Countdown Mode
- Calculates: `nextFeedTime = lastFeedTimestamp + feedIntervalMinutes`
- Displays: Time remaining until `nextFeedTime`
- When timer reaches 0:
  - Display changes to "00:00" in red/danger color
  - Status text shows "Feed Overdue"
  - Notification fires (if permitted)
  - Chime plays (if app is in foreground)
  - Live Activity updates to show overdue state

#### Stopwatch Mode
- Calculates: `elapsed = now - lastFeedTimestamp`
- Displays: Time since last feed
- No alarm trigger in this mode (notifications still fire based on interval)

#### Background Behavior
- Timer calculations are time-based, not dependent on app running
- On app launch/foreground: Recalculate based on current time and last feed
- Local notifications scheduled for exact feed due time
- Live Activity uses `Date` with `.timer` style for system-managed countdown

### 5.2 Feed Logging

#### Quick Log Flow
1. User taps "Start Feed" button
2. System creates `FeedEvent` with:
   - `timestamp = Date()`
   - `type = settings.defaultFeedType`
   - `baby = currentBaby`
3. Timer resets
4. Notification rescheduled
5. Live Activity updated
6. Random encouragement message displayed

#### Edit Flow
1. User taps event in history list
2. Edit sheet presents with fields:
   - Date/time picker
   - Type selector (chips)
   - Duration (quick buttons: 5, 10, 15, 20, 25, 30 + manual input)
   - Amount (ml) - optional
   - Formula type (if type == .formula)
   - Notes
3. Save updates local record
4. If sync enabled, mark `needsSync = true`

### 5.3 Diaper Logging

#### Quick Log Flow
1. User taps Wet/Dirty/Both button
2. System creates `DiaperEvent` with:
   - `timestamp = Date()`
   - `type` based on button
   - `baby = currentBaby`
3. Event appears in history

#### Edit Flow
Same as feed editing, minus feed-specific fields.

### 5.4 History & Statistics

#### Statistics Calculations

```swift
// 24-hour feed count
let feedCount24h = feedEvents.filter { 
    $0.timestamp > Date().addingTimeInterval(-24 * 60 * 60) 
}.count

// Average interval (last 10 feeds)
let recentFeeds = feedEvents.prefix(11) // Need 11 to calculate 10 intervals
var intervals: [TimeInterval] = []
for i in 0..<(recentFeeds.count - 1) {
    let interval = recentFeeds[i].timestamp.timeIntervalSince(recentFeeds[i + 1].timestamp)
    intervals.append(interval)
}
let avgInterval = intervals.reduce(0, +) / Double(intervals.count)

// 24-hour diaper counts
let diapers24h = diaperEvents.filter { 
    $0.timestamp > Date().addingTimeInterval(-24 * 60 * 60) 
}
let wetCount = diapers24h.filter { $0.type == .wet || $0.type == .both }.count
let dirtyCount = diapers24h.filter { $0.type == .dirty || $0.type == .both }.count
```

#### Export Format

```json
{
  "exportDate": "2025-11-27T10:30:00Z",
  "appVersion": "1.0.0",
  "babies": [
    {
      "id": "uuid",
      "name": "Baby Name",
      "birthDate": "2025-10-01",
      "feedIntervalMinutes": 150
    }
  ],
  "feedEvents": [
    {
      "id": "uuid",
      "babyId": "uuid",
      "timestamp": "2025-11-27T08:00:00Z",
      "type": "Both",
      "durationMinutes": 15,
      "amountML": null,
      "formulaType": null,
      "notes": ""
    }
  ],
  "diaperEvents": [
    {
      "id": "uuid",
      "babyId": "uuid",
      "timestamp": "2025-11-27T09:00:00Z",
      "type": "Wet",
      "notes": ""
    }
  ]
}
```

### 5.5 Baby Profiles

#### Profile Management
- Create new baby profile (name required, birthdate optional)
- Set feed interval per baby
- Switch between babies via dropdown/picker
- Delete baby (with confirmation, cascades to all events)

#### Default Behavior
- First launch: Prompt to create first baby profile during onboarding
- If only one baby: No switcher shown, automatic selection
- If multiple babies: Switcher in header, persisted selection

### 5.6 Settings

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Feed Interval | Picker | 2.5 hours | Per-baby setting |
| Theme | Picker | Dark | Dark/Light/System |
| Alarm Sound | Picker | Soft Chime | Preview on selection |
| Default Feed Type | Picker | Both | Used for quick-log |
| Default Formula Type | Text | Empty | Pre-fills formula field |
| Family Sync | Toggle | Off | Requires purchase |

---

## 6. User Interface Design

### 6.1 Design System

#### Color Palette

**Dark Theme (Default)**
```swift
struct DarkTheme {
    static let background = Color(hex: "1e1e2e")      // Deep purple-gray
    static let surface = Color(hex: "313244")         // Elevated surface
    static let textPrimary = Color(hex: "cdd6f4")     // Off-white
    static let textSecondary = Color(hex: "a6adc8")   // Muted
    static let accent = Color(hex: "89b4fa")          // Soft blue
    static let accentSecondary = Color(hex: "cba6f7") // Soft purple
    static let danger = Color(hex: "f38ba8")          // Soft red
    static let success = Color(hex: "a6e3a1")         // Soft green
}
```

**Light Theme**
```swift
struct LightTheme {
    static let background = Color(hex: "eff1f5")
    static let surface = Color.white
    static let textPrimary = Color(hex: "4c4f69")
    static let textSecondary = Color(hex: "6c6f85")
    static let accent = Color(hex: "1e66f5")
    static let accentSecondary = Color(hex: "8839ef")
    static let danger = Color(hex: "d20f39")
    static let success = Color(hex: "40a02b")
}
```

#### Typography
- Primary: SF Pro (system default)
- Timer Display: SF Pro with `.monospacedDigit()` modifier
- Sizes:
  - Timer: 72pt, ultraLight weight
  - Headers: 20pt, semibold
  - Body: 17pt, regular
  - Caption: 14pt, regular

#### Spacing
- Base unit: 8pt
- Standard padding: 16pt (2 units)
- Section spacing: 24pt (3 units)
- Corner radius: 16pt (cards), 20pt (buttons), 12pt (chips)

### 6.2 Screen Layouts

#### Home Screen

```
┌─────────────────────────────────────────┐
│ 10:30 AM                          ⚙️    │  ← Header: Clock + Settings
├─────────────────────────────────────────┤
│                                         │
│     ┌───────────────────────────┐       │
│     │ [Next Feed] │ [Since Last]│       │  ← Mode Toggle
│     └───────────────────────────┘       │
│                                         │
│              1:23:45                    │  ← Main Timer Display
│           Due at 11:53 AM               │  ← Sub Display
│                                         │
│         "You're doing great!"           │  ← Encouragement
│                                         │
│     ┌───────────────────────────┐       │
│     │        Start Feed         │       │  ← Primary Action
│     └───────────────────────────┘       │
│                                         │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│   │ 💧 Wet  │ │ 💩 Dirty│ │💧💩 Both│   │  ← Diaper Quick Actions
│   └─────────┘ └─────────┘ └─────────┘   │
│                                         │
├─────────────────────────────────────────┤
│ Recent Activity          [History >]    │  ← Section Header
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🤱  9:30 AM (Today)           Edit │ │  ← Event Row
│ │     Both • 15m                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 💧  9:15 AM (Today)           Edit │ │
│ │     Wet Diaper                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 🤱  6:30 AM (Today)           Edit │ │
│ │     Both • 20m                     │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### History & Stats Screen

```
┌─────────────────────────────────────────┐
│ History & Stats                  Close  │
├─────────────────────────────────────────┤
│                                         │
│   ┌─────────────┐  ┌─────────────┐      │
│   │ Feeds (24h) │  │ Avg Interval│      │
│   │     8       │  │    2.5h     │      │
│   └─────────────┘  └─────────────┘      │
│   ┌─────────────┐  ┌─────────────┐      │
│   │  Wet (24h)  │  │ Dirty (24h) │      │
│   │     6       │  │     4       │      │
│   └─────────────┘  └─────────────┘      │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │         Export Data (JSON)      │   │
│   └─────────────────────────────────┘   │
│   ┌─────────────────────────────────┐   │
│   │         Import Data (JSON)      │   │
│   └─────────────────────────────────┘   │
│                                         │
├─────────────────────────────────────────┤
│ All Events                              │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 🤱  9:30 AM (Nov 27)          Edit │ │
│ │     Both • 15m                     │ │
│ └─────────────────────────────────────┘ │
│                 ...                     │
└─────────────────────────────────────────┘
```

#### Settings Screen

```
┌─────────────────────────────────────────┐
│ Settings                         Close  │
├─────────────────────────────────────────┤
│                                         │
│ TIMER                                   │
│ ┌─────────────────────────────────────┐ │
│ │ Feed Interval            [2.5 hrs ▼]│ │
│ └─────────────────────────────────────┘ │
│                                         │
│ APPEARANCE                              │
│ ┌─────────────────────────────────────┐ │
│ │ Theme                       [Dark ▼]│ │
│ └─────────────────────────────────────┘ │
│                                         │
│ NOTIFICATIONS                           │
│ ┌─────────────────────────────────────┐ │
│ │ Alarm Sound           [Soft Chime ▼]│ │
│ ├─────────────────────────────────────┤ │
│ │ Test Sound                      [▶] │ │
│ ├─────────────────────────────────────┤ │
│ │ Test Notification               [▶] │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ DEFAULTS                                │
│ ┌─────────────────────────────────────┐ │
│ │ Default Feed Type           [Both ▼]│ │
│ ├─────────────────────────────────────┤ │
│ │ Default Formula Type      [Similac] │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ FAMILY SYNC                             │
│ ┌─────────────────────────────────────┐ │
│ │ ☁️ Enable Family Sync               │ │
│ │ Sync data across devices and share  │ │
│ │ with your partner.                  │ │
│ │                                     │ │
│ │      [Unlock for $0.99]             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ BABIES                                  │
│ ┌─────────────────────────────────────┐ │
│ │ 👶 Emma                          ▶  │ │
│ ├─────────────────────────────────────┤ │
│ │ + Add Baby                          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ DATA                                    │
│ ┌─────────────────────────────────────┐ │
│ │ 🗑️ Clear All Data                   │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

#### Edit Event Sheet

```
┌─────────────────────────────────────────┐
│ Edit Entry                              │
├─────────────────────────────────────────┤
│                                         │
│ Time                                    │
│ ┌─────────────────────────────────────┐ │
│ │ Nov 27, 2025  9:30 AM               │ │  ← DateTime Picker
│ └─────────────────────────────────────┘ │
│                                         │
│ Type                                    │
│ ┌──────┐┌──────┐┌──────┐┌──────┐┌─────┐│
│ │ Left ││Right ││ Both ││Bottle││Form ││  ← Chip Selector
│ └──────┘└──────┘└──────┘└──────┘└─────┘│
│                                         │
│ Duration (minutes)                      │
│ ┌────┐┌────┐┌────┐┌────┐┌────┐┌────┐   │
│ │ 5  ││ 10 ││ 15 ││ 20 ││ 25 ││ 30 │   │  ← Quick Buttons
│ └────┘└────┘└────┘└────┘└────┘└────┘   │
│ ┌─────────────────────────────────────┐ │
│ │ 15                                  │ │  ← Manual Input
│ └─────────────────────────────────────┘ │
│                                         │
│ Amount (ml) - Optional                  │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Notes                                   │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
├─────────────────────────────────────────┤
│ [Delete]              [Cancel]  [Save]  │
└─────────────────────────────────────────┘
```

### 6.3 Animations & Transitions

- **View transitions:** Slide up from bottom (modal style)
- **List items:** Fade in with slight upward movement on appear
- **Timer updates:** No animation (instant update for readability)
- **Button press:** Scale to 98% on press
- **Mode toggle:** Background slides to selected button

---

## 7. CloudKit & Sync Architecture

### 7.1 Overview

CloudKit sync is a **paid feature** unlocked via one-time $0.99 purchase. When enabled:

1. All data syncs to user's private CloudKit database
2. User can share their Baby record with family members via CKShare
3. Changes from any device propagate to all shared users
4. Offline changes queue and sync when connectivity returns

### 7.2 CloudKit Setup

#### Container Configuration
- Container ID: `iCloud.com.yourcompany.nurture`
- Database: Private Database (data tied to user's iCloud account)
- Sharing: CKShare for family sharing

#### Record Types

```
CD_Baby
├── id: String (UUID)
├── name: String
├── birthDate: Date?
├── feedIntervalMinutes: Int64
├── createdAt: Date
├── modifiedAt: Date

CD_FeedEvent
├── id: String (UUID)
├── timestamp: Date
├── type: String
├── durationMinutes: Int64?
├── amountML: Int64?
├── formulaType: String?
├── notes: String?
├── createdAt: Date
├── modifiedAt: Date
├── createdByDeviceID: String?
├── baby: Reference → CD_Baby

CD_DiaperEvent
├── id: String (UUID)
├── timestamp: Date
├── type: String
├── notes: String?
├── createdAt: Date
├── modifiedAt: Date
├── createdByDeviceID: String?
├── baby: Reference → CD_Baby
```

### 7.3 Sync Engine Design

```swift
class SyncEngine: ObservableObject {
    @Published var syncStatus: SyncStatus = .idle
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    enum SyncStatus {
        case idle
        case syncing
        case error(Error)
        case offline
    }
    
    // MARK: - Core Operations
    
    func performFullSync() async throws {
        // 1. Push local changes
        try await pushPendingChanges()
        
        // 2. Fetch remote changes
        try await fetchRemoteChanges()
        
        // 3. Resolve any conflicts (last-write-wins)
        resolveConflicts()
    }
    
    func pushPendingChanges() async throws {
        // Query for records with needsSync == true
        // Convert to CKRecord
        // Batch save to CloudKit
    }
    
    func fetchRemoteChanges() async throws {
        // Use CKFetchRecordZoneChangesOperation for incremental sync
        // Store server change token locally
        // Merge incoming records with local data
    }
    
    // MARK: - Sharing
    
    func createShare(for baby: Baby) async throws -> CKShare {
        // Create CKShare with baby record as root
        // Configure share options
        // Return share for UICloudSharingController
    }
    
    func acceptShare(_ metadata: CKShare.Metadata) async throws {
        // Accept incoming share
        // Fetch shared records
        // Add to local database
    }
}
```

### 7.4 Conflict Resolution

**Strategy: Last-Write-Wins**

```swift
func resolveConflict(local: FeedEvent, remote: CKRecord) -> FeedEvent {
    let remoteModified = remote["modifiedAt"] as? Date ?? Date.distantPast
    
    if local.modifiedAt > remoteModified {
        // Local wins - push local to CloudKit
        return local
    } else {
        // Remote wins - update local from CloudKit
        return FeedEvent(from: remote)
    }
}
```

### 7.5 Family Sharing Flow

#### Inviting a Partner

```
1. Owner taps "Share with Partner" in settings
2. App creates CKShare for selected Baby record
3. System share sheet appears (Messages, Email, AirDrop, etc.)
4. Partner receives link
5. Partner opens link → Nurture app launches
6. App calls acceptShare() with metadata
7. Shared baby appears in partner's app
8. Both users now see same data in real-time
```

#### Share Permissions
- Participants can: Read, Write (add/edit events)
- Only owner can: Delete baby profile, Revoke access

---

## 8. Live Activities & Notifications

### 8.1 Live Activity Implementation

#### Activity Attributes

```swift
import ActivityKit

struct FeedTimerAttributes: ActivityAttributes {
    // Static data (doesn't change during activity)
    public struct ContentState: Codable, Hashable {
        var feedDueAt: Date
        var isOverdue: Bool
        var viewMode: String // "countdown" or "stopwatch"
        var lastFeedTime: Date
    }
    
    var babyName: String
}
```

#### Lock Screen UI

```swift
struct FeedTimerLockScreenView: View {
    let context: ActivityViewContext<FeedTimerAttributes>
    
    var body: some View {
        HStack {
            // Left: Icon and baby name
            VStack(alignment: .leading) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.purple)
                Text(context.attributes.babyName)
                    .font(.caption)
            }
            
            Spacer()
            
            // Right: Timer
            if context.state.viewMode == "countdown" {
                if context.state.isOverdue {
                    Text("Feed Now!")
                        .foregroundColor(.red)
                        .font(.headline)
                } else {
                    Text(context.state.feedDueAt, style: .timer)
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                        .monospacedDigit()
                }
            } else {
                Text(context.state.lastFeedTime, style: .timer)
                    .font(.system(size: 32, weight: .light, design: .monospaced))
                    .monospacedDigit()
            }
        }
        .padding()
    }
}
```

#### Dynamic Island Views

```swift
// Compact (default state)
struct CompactLeadingView: View {
    let context: ActivityViewContext<FeedTimerAttributes>
    
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.purple)
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<FeedTimerAttributes>
    
    var body: some View {
        Text(context.state.feedDueAt, style: .timer)
            .monospacedDigit()
            .font(.caption)
    }
}

// Expanded (long press)
struct ExpandedView: View {
    let context: ActivityViewContext<FeedTimerAttributes>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Next Feed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(context.state.feedDueAt, style: .timer)
                    .font(.title)
                    .monospacedDigit()
            }
            Spacer()
            // Quick action button
            Link(destination: URL(string: "nurture://startFeed")!) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
            }
        }
        .padding()
    }
}

// Minimal (multiple activities)
struct MinimalView: View {
    let context: ActivityViewContext<FeedTimerAttributes>
    
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.purple)
    }
}
```

#### Activity Lifecycle

```swift
class LiveActivityService {
    private var currentActivity: Activity<FeedTimerAttributes>?
    
    func startActivity(baby: Baby, feedDueAt: Date, viewMode: TimerViewMode, lastFeedTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = FeedTimerAttributes(babyName: baby.name)
        let state = FeedTimerAttributes.ContentState(
            feedDueAt: feedDueAt,
            isOverdue: feedDueAt < Date(),
            viewMode: viewMode.rawValue,
            lastFeedTime: lastFeedTime
        )
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateActivity(feedDueAt: Date, isOverdue: Bool, viewMode: TimerViewMode, lastFeedTime: Date) async {
        let state = FeedTimerAttributes.ContentState(
            feedDueAt: feedDueAt,
            isOverdue: isOverdue,
            viewMode: viewMode.rawValue,
            lastFeedTime: lastFeedTime
        )
        
        await currentActivity?.update(
            ActivityContent(state: state, staleDate: nil)
        )
    }
    
    func endActivity() async {
        await currentActivity?.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
    }
}
```

### 8.2 Local Notifications

#### Notification Setup

```swift
class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
    
    func scheduleFeedReminder(at date: Date, babyName: String, sound: AlarmSound) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing feed reminders
        center.removePendingNotificationRequests(withIdentifiers: ["feedReminder"])
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Time to Feed!"
        content.body = "It's been \(formattedInterval) since \(babyName)'s last feed."
        content.sound = sound.notificationSound
        content.interruptionLevel = .timeSensitive // Breaks through Focus
        
        // Create trigger
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "feedReminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension AlarmSound {
    var notificationSound: UNNotificationSound {
        switch self {
        case .softChime:
            return UNNotificationSound(named: UNNotificationSoundName("chime1.caf"))
        case .gentleBell:
            return UNNotificationSound(named: UNNotificationSoundName("chime2.caf"))
        case .harp:
            return UNNotificationSound(named: UNNotificationSoundName("chime3.caf"))
        case .silent:
            return .none
        }
    }
}
```

#### Custom Notification Sounds

Custom sounds must be:
- Format: CAF, AIFF, or WAV (linear PCM or IMA4)
- Duration: ≤ 30 seconds
- Location: App bundle or Library/Sounds directory

We'll synthesize the chimes and export as CAF files for the bundle.

### 8.3 Background Processing

```swift
// In AppDelegate or App struct
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    // Register for background app refresh
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.nurture.refresh",
        using: nil
    ) { task in
        self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }
}

func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.nurture.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 min
    
    try? BGTaskScheduler.shared.submit(request)
}

func handleAppRefresh(task: BGAppRefreshTask) {
    // Update Live Activity if needed
    // Sync with CloudKit if enabled
    // Reschedule next refresh
    
    task.setTaskCompleted(success: true)
    scheduleAppRefresh()
}
```

---

## 9. In-App Purchase Implementation

### 9.1 Product Configuration

#### App Store Connect Setup
- **Product ID:** `com.nurture.familysync`
- **Type:** Non-Consumable
- **Price:** $0.99 (Tier 1)
- **Display Name:** Family Sync
- **Description:** Sync your data across all your devices and share with your partner in real-time.

### 9.2 StoreKit 2 Implementation

```swift
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    @Published var familySyncProduct: Product?
    @Published var hasFamilySync: Bool = false
    @Published var purchaseState: PurchaseState = .idle
    
    enum PurchaseState {
        case idle
        case purchasing
        case purchased
        case failed(Error)
    }
    
    private let productID = "com.nurture.familysync"
    
    init() {
        Task {
            await loadProducts()
            await checkEntitlements()
            await listenForTransactions()
        }
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            familySyncProduct = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    
    func purchaseFamilySync() async {
        guard let product = familySyncProduct else { return }
        
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                hasFamilySync = true
                purchaseState = .purchased
                await transaction.finish()
                
            case .userCancelled:
                purchaseState = .idle
                
            case .pending:
                purchaseState = .idle
                
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error)
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            print("Restore failed: \(error)")
        }
    }
    
    // MARK: - Check Entitlements
    
    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID {
                    hasFamilySync = true
                    return
                }
            }
        }
        hasFamilySync = false
    }
    
    // MARK: - Transaction Listener
    
    func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if transaction.productID == productID {
                    hasFamilySync = true
                }
                await transaction.finish()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum PurchaseError: Error {
    case failedVerification
}
```

### 9.3 Purchase UI

```swift
struct FamilySyncPurchaseView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "icloud.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            // Title
            Text("Family Sync")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Description
            Text("Sync data across all your devices and share with your partner in real-time.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Features
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Sync across devices")
                FeatureRow(icon: "person.2.fill", text: "Share with partner")
                FeatureRow(icon: "wifi.slash", text: "Works offline")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Price Button
            if let product = purchaseManager.familySyncProduct {
                Button {
                    Task {
                        await purchaseManager.purchaseFamilySync()
                    }
                } label: {
                    HStack {
                        Text("Unlock for")
                        Text(product.displayPrice)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(purchaseManager.purchaseState == .purchasing)
            }
            
            // Restore Button
            Button("Restore Purchases") {
                Task {
                    await purchaseManager.restorePurchases()
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}
```

---

## 10. Development Phases

### Phase 1: Foundation (Week 1-2)

**Goal:** Basic app shell with local data persistence

- [ ] Create Xcode project with SwiftUI lifecycle
- [ ] Set up SwiftData models (Baby, FeedEvent, DiaperEvent, UserSettings)
- [ ] Implement NurtureManager as main state coordinator
- [ ] Build HomeView with timer display (countdown/stopwatch)
- [ ] Implement "Start Feed" functionality
- [ ] Build event history list
- [ ] Create edit event sheet
- [ ] Port CSS color scheme to SwiftUI theme system

**Deliverable:** App that can log feeds, display timer, show history (local only)

### Phase 2: Full Local Features (Week 3-4)

**Goal:** Feature parity with PWA

- [ ] Add diaper tracking (quick buttons, edit, stats)
- [ ] Build Settings screen with all options
- [ ] Implement baby profile management (create, edit, switch, delete)
- [ ] Add onboarding flow for first launch
- [ ] Implement data export (JSON)
- [ ] Implement data import (JSON)
- [ ] Add all three chime sounds (synthesized or audio files)
- [ ] Build theme switching (dark/light/system)
- [ ] Add encouragement messages rotation

**Deliverable:** Fully functional local app matching PWA features

### Phase 3: Notifications & Live Activities (Week 5-6)

**Goal:** Background alerting and Lock Screen presence

- [ ] Request and handle notification permissions
- [ ] Schedule local notifications for feed due time
- [ ] Create custom notification sounds (CAF format)
- [ ] Implement time-sensitive notification category
- [ ] Build Live Activity extension
- [ ] Design Lock Screen Live Activity UI
- [ ] Design Dynamic Island views (compact, expanded, minimal)
- [ ] Implement activity start/update/end lifecycle
- [ ] Add URL scheme for deep linking from Live Activity
- [ ] Test background behavior and notification reliability

**Deliverable:** App with reliable alerts and Lock Screen timer display

### Phase 4: CloudKit & Sync (Week 7-8)

**Goal:** Multi-device sync foundation

- [ ] Create CloudKit container in developer portal
- [ ] Define CloudKit record types
- [ ] Build SyncEngine class
- [ ] Implement push local changes to CloudKit
- [ ] Implement fetch remote changes from CloudKit
- [ ] Handle offline queueing
- [ ] Implement conflict resolution (last-write-wins)
- [ ] Test sync between two devices (same iCloud account)

**Deliverable:** Data syncs between user's own devices when enabled

### Phase 5: Family Sharing (Week 9-10)

**Goal:** Share data with partner

- [ ] Implement CKShare creation for Baby record
- [ ] Build share invitation UI (using UICloudSharingController)
- [ ] Handle incoming share acceptance
- [ ] Test share flow between two different iCloud accounts
- [ ] Ensure proper permission handling (read/write for participants)
- [ ] Add "Shared with: [names]" indicator in UI
- [ ] Handle share revocation

**Deliverable:** Two different users can share and sync a baby profile

### Phase 6: In-App Purchase (Week 11)

**Goal:** Monetize Family Sync feature

- [ ] Configure product in App Store Connect (Sandbox first)
- [ ] Implement PurchaseManager with StoreKit 2
- [ ] Build purchase UI in Settings
- [ ] Gate CloudKit sync behind purchase check
- [ ] Implement restore purchases
- [ ] Test purchase flow in Sandbox
- [ ] Test transaction listener for interrupted purchases

**Deliverable:** Family Sync requires $0.99 purchase to enable

### Phase 7: Polish & Testing (Week 12-13)

**Goal:** Production-ready quality

- [ ] Comprehensive UI polish pass
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Performance profiling and optimization
- [ ] Memory leak detection
- [ ] Edge case testing (no data, lots of data, poor connectivity)
- [ ] Device testing (various iPhone sizes, iPad)
- [ ] Beta testing via TestFlight
- [ ] Gather and incorporate feedback

**Deliverable:** Stable, polished app ready for review

### Phase 8: App Store Submission (Week 14)

**Goal:** Published app

- [ ] Prepare App Store Connect listing
  - [ ] App name, subtitle, keywords
  - [ ] Description
  - [ ] Screenshots (6.7", 6.5", 5.5" iPhone + iPad)
  - [ ] App icon (1024x1024)
  - [ ] Privacy policy URL
  - [ ] Support URL
- [ ] Submit for review
- [ ] Address any review feedback
- [ ] Launch! 🚀

---

## 11. File & Project Structure

```
Nurture/
├── Nurture.xcodeproj
├── Nurture/
│   ├── NurtureApp.swift                 # App entry point
│   ├── ContentView.swift                # Root view with navigation
│   │
│   ├── Models/
│   │   ├── Baby.swift                   # SwiftData model
│   │   ├── FeedEvent.swift              # SwiftData model
│   │   ├── DiaperEvent.swift            # SwiftData model
│   │   ├── UserSettings.swift           # SwiftData model
│   │   └── Enums.swift                  # FeedType, DiaperType, etc.
│   │
│   ├── Managers/
│   │   ├── NurtureManager.swift         # Main state coordinator
│   │   ├── PurchaseManager.swift        # StoreKit 2 handling
│   │   └── SyncEngine.swift             # CloudKit sync logic
│   │
│   ├── Services/
│   │   ├── TimerService.swift           # Countdown/stopwatch logic
│   │   ├── NotificationService.swift    # Local notifications
│   │   ├── AudioService.swift           # Chime playback
│   │   └── LiveActivityService.swift    # ActivityKit management
│   │
│   ├── Views/
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   ├── TimerDisplayView.swift
│   │   │   ├── QuickActionsView.swift
│   │   │   └── RecentActivityView.swift
│   │   │
│   │   ├── History/
│   │   │   ├── HistoryView.swift
│   │   │   ├── StatsGridView.swift
│   │   │   └── EventRowView.swift
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── BabyProfileView.swift
│   │   │   ├── FamilySyncView.swift
│   │   │   └── AboutView.swift
│   │   │
│   │   ├── Sheets/
│   │   │   ├── EditEventSheet.swift
│   │   │   ├── AddBabySheet.swift
│   │   │   └── OnboardingSheet.swift
│   │   │
│   │   └── Components/
│   │       ├── ChipSelector.swift
│   │       ├── StatCard.swift
│   │       ├── PrimaryButton.swift
│   │       └── QuickDurationButtons.swift
│   │
│   ├── Theme/
│   │   ├── Theme.swift                  # Color definitions
│   │   ├── ThemeManager.swift           # Theme switching logic
│   │   └── Typography.swift             # Font styles
│   │
│   ├── Utilities/
│   │   ├── DateFormatters.swift
│   │   ├── TimeFormatters.swift
│   │   ├── Encouragements.swift         # Message array
│   │   └── Extensions/
│   │       ├── Color+Hex.swift
│   │       ├── Date+Helpers.swift
│   │       └── View+Conditionals.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/
│   │   │   ├── Colors/
│   │   │   └── Images/
│   │   ├── Sounds/
│   │   │   ├── chime1.caf
│   │   │   ├── chime2.caf
│   │   │   └── chime3.caf
│   │   └── Localizable.strings          # Future localization
│   │
│   └── Info.plist
│
├── NurtureWidgets/                       # Widget Extension (Future)
│   └── ...
│
├── NurtureLiveActivity/                  # Live Activity Extension
│   ├── NurtureLiveActivityBundle.swift
│   ├── FeedTimerAttributes.swift
│   ├── FeedTimerLiveActivity.swift
│   └── Info.plist
│
├── NurtureTests/
│   ├── ModelTests/
│   ├── ManagerTests/
│   └── ServiceTests/
│
└── NurtureUITests/
    └── ...
```

---

## 12. Testing Strategy

### Unit Tests

| Component | Test Cases |
|-----------|-----------|
| `FeedEvent` | Creation, property updates, relationship to Baby |
| `DiaperEvent` | Creation, type handling |
| `Baby` | Creation, feed interval updates, cascading deletes |
| `TimerService` | Countdown calculation, stopwatch calculation, overdue detection |
| `NurtureManager` | Stats calculations (24h counts, average interval) |
| `SyncEngine` | Conflict resolution, record mapping |

### Integration Tests

- SwiftData persistence across app launches
- CloudKit sync round-trip (push then fetch)
- Notification scheduling and delivery
- Live Activity lifecycle

### UI Tests

- Onboarding flow completion
- Log feed → appears in history
- Edit event → changes persist
- Settings changes → apply immediately
- Purchase flow (Sandbox)

### Manual Testing Checklist

- [ ] Fresh install experience
- [ ] Upgrade from v1.0 to v1.1 (data migration if needed)
- [ ] Offline usage for 24+ hours
- [ ] Kill app → notification still fires
- [ ] Background for 8 hours → Live Activity still accurate
- [ ] Two devices sync simultaneously
- [ ] Partner accepts share invitation
- [ ] Purchase → sync enables
- [ ] Restore purchase on new device
- [ ] Accessibility: VoiceOver navigation
- [ ] Accessibility: Dynamic Type (largest sizes)
- [ ] Low battery mode behavior
- [ ] Airplane mode → offline indicators

---

## 13. App Store Preparation

### App Information

- **App Name Options** (check availability):
  1. Nurture — Newborn Tracker
  2. Nurture Baby
  3. Little Nurture
  4. Nurture Feed Timer
  5. Nourish Baby Tracker

- **Subtitle:** Calm feeding & diaper tracking

- **Keywords:** newborn, baby, feeding, tracker, timer, breastfeeding, bottle, diaper, infant, nursing, schedule, reminder, parent

- **Category:** Primary: Health & Fitness, Secondary: Lifestyle

- **Age Rating:** 4+ (no objectionable content)

### Description

```
Nurture is a calm, simple way to track your newborn's feeding schedule and diaper changes during those exhausting first months.

FEATURES

• Countdown & Stopwatch — See exactly when the next feed is due, or how long it's been since the last one.

• One-Tap Logging — Start a feed or log a diaper change with a single tap. No fumbling at 3am.

• Live Activities — See your timer right on your Lock Screen and Dynamic Island without opening the app.

• Smart Reminders — Gentle notifications when it's time to feed, with soothing chimes designed not to startle.

• History & Stats — Track 24-hour feeding and diaper counts, average intervals, and export your data.

• Family Sync (Optional) — Share your tracking space with your partner so you're both on the same page. Requires one-time $0.99 purchase.

• Beautiful Design — Dark and light themes with a calming color palette designed for late-night use.

• Offline First — Works perfectly without internet. Your data stays on your device.

Built with 💜 for sleep-deprived parents everywhere.
```

### Screenshots Needed

| Device | Screens |
|--------|---------|
| iPhone 6.7" (15 Pro Max) | Home, History, Settings, Live Activity, Edit Sheet |
| iPhone 6.5" (11 Pro Max) | Same 5 screens |
| iPhone 5.5" (8 Plus) | Same 5 screens |
| iPad Pro 12.9" | Same 5 screens (if universal) |

### Privacy Policy Requirements

Must disclose:
- Local data storage (device only)
- CloudKit data storage (if sync enabled, stored in user's iCloud)
- No third-party analytics or advertising
- No data sold or shared

### App Privacy Labels

- **Data Not Collected** — if no analytics
- OR **Data Linked to You:**
  - Health & Fitness (feeding/diaper data) — stored in iCloud if sync enabled
  - Identifiers (device ID for sync conflict resolution)

---

## 14. Future Roadmap

### Version 1.1 — Widgets
- Home Screen widgets showing:
  - Next feed countdown
  - Last feed time
  - 24h stats summary

### Version 1.2 — Apple Watch
- watchOS companion app
- Quick log feed/diaper from wrist
- Complication showing timer

### Version 1.3 — Growth Tracking
- Weight logging
- Growth chart visualization
- Percentile calculations

### Version 1.4 — Sleep Tracking
- Log sleep start/end
- Sleep duration stats
- Correlate with feeding patterns

### Version 1.5 — Pumping Support
- Dedicated pumping session logging
- Volume tracking
- Pump output statistics

### Version 2.0 — Multi-Child
- Enhanced UI for multiple babies
- Per-child settings and stats
- Family overview dashboard

---

## 15. Technical Decisions Log

| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| UI Framework | SwiftUI | Modern, declarative, great for this complexity level | Nov 2025 |
| Local Storage | SwiftData | Native Apple framework, SwiftUI integration, CloudKit compatible | Nov 2025 |
| Cloud Sync | CloudKit | Free for users, native, handles offline, built-in sharing | Nov 2025 |
| Min iOS Version | 17.0 | SwiftData requires 17, Live Activities mature in 17 | Nov 2025 |
| Monetization | $0.99 non-consumable | Low barrier, offsets any CloudKit costs, simple implementation | Nov 2025 |
| Timer Implementation | Date-based calculation | Doesn't rely on app running, survives force-quit | Nov 2025 |
| Conflict Resolution | Last-write-wins | Simple to implement, appropriate for this data type | Nov 2025 |
| Notification Timing | Exact time scheduling | Critical for feeding reminders to be reliable | Nov 2025 |
| Multi-baby Support | Built-in from v1.0 | Easier to architect upfront than migrate later | Nov 2025 |

---

## 16. Resources & References

### Apple Documentation

- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [CloudKit](https://developer.apple.com/documentation/cloudkit)
- [ActivityKit (Live Activities)](https://developer.apple.com/documentation/activitykit)
- [StoreKit 2](https://developer.apple.com/documentation/storekit/in-app_purchase)
- [User Notifications](https://developer.apple.com/documentation/usernotifications)
- [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)

### WWDC Sessions

- WWDC23: Meet SwiftData
- WWDC23: Build apps that integrate with ActivityKit
- WWDC22: What's new in StoreKit 2
- WWDC21: Meet CloudKit Console

### Design Resources

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

### Tools

- Xcode 15+
- CloudKit Console (developer.apple.com)
- App Store Connect

---

## Appendix A: Encouragement Messages

```swift
let encouragements = [
    "You're doing great!",
    "One feed at a time.",
    "You got this!",
    "Deep breaths.",
    "Remember to hydrate.",
    "Super parent mode: ON",
    "Doing an amazing job.",
    "Love grows here.",
    "Rest when you can.",
    "You're their whole world.",
    "This too shall pass.",
    "Tiny victories matter.",
    "You're exactly the parent they need.",
    "Trust your instincts.",
    "Every feed is a gift of love."
]
```

---

## Appendix B: URL Schemes

```
nurture://                    → Opens app to Home
nurture://startFeed           → Opens app and immediately logs feed
nurture://history             → Opens app to History view
nurture://settings            → Opens app to Settings view
```

Configure in Info.plist:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.nurture.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>nurture</string>
        </array>
    </dict>
</array>
```

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 2025 | Initial comprehensive plan |

---

*This document serves as the single source of truth for the Nurture iOS app development. Update as decisions evolve.*
