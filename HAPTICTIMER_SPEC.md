# HapticTimer - Complete Technical Specification

**Version:** 1.1
**Target Platform:** iOS 17+
**Last Updated:** January 14, 2026
**Developer:** Mathias Jaeger-Pedersen

> **📝 LIVING DOCUMENT:** This specification is updated throughout development to reflect actual implementation decisions and design changes. The spec evolves with the project to maintain accuracy and serve as the single source of truth.

---

## Recent Changes
- **v1.1 (Jan 14, 2026):** Changed from "cut arc" design to full circle. Time display moved to center with tap-to-edit instead of always-visible picker.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Technical Stack](#technical-stack)
3. [App Architecture](#app-architecture)
4. [Core Features](#core-features)
5. [User Interface Specifications](#user-interface-specifications)
6. [Data Models](#data-models)
7. [Haptic System](#haptic-system)
8. [Timer Engine](#timer-engine)
9. [In-App Purchase System](#in-app-purchase-system)
10. [Background Execution](#background-execution)
11. [Implementation Roadmap](#implementation-roadmap)
12. [Testing Requirements](#testing-requirements)
13. [Edge Cases & Error Handling](#edge-cases--error-handling)

---

## Project Overview

### Concept
HapticTimer is a unique iOS timer application that uses custom haptic feedback patterns to alert users at configurable time intervals. Unlike traditional timers that rely on sound, HapticTimer provides distinct vibration patterns that allow users to know exactly how much time remains without looking at their device.

### Key Differentiators
- **Circular touch interface** for intuitive haptic point placement
- **Drag-to-adjust timing** with 30-second snap intervals
- **Pattern-based alerts** - each time interval has a unique haptic pattern
- **Premium tier** with advanced customization
- **No interaction required** - haptic alerts auto-dismiss after a few seconds

### Use Cases
- **Workout intervals** - Feel different patterns for warm-up, work, and rest periods
- **Meditation/Breathing** - Non-intrusive timing guidance
- **Cooking** - Check doneness without touching phone with messy hands
- **Presentations** - Discrete time warnings during talks
- **Study sessions** - Pomodoro-style timing with haptic alerts

### Business Model
- **Free Tier:** Single timer, 3 custom haptic points, orange circle, no saves
- **Premium Tier:** $4.99 one-time purchase
  - 5 custom haptic points
  - 15 saved timer configurations
  - 10 circle colors
  - Full customization

---

## Technical Stack

### Core Technologies
```
Platform:          iOS 17.0+
Language:          Swift 5.9+
UI Framework:      SwiftUI
Architecture:      MVVM (Model-View-ViewModel)
Storage:           SwiftData
Purchases:         StoreKit 2
Haptics:           Core Haptics Framework
Background:        Background Tasks + Live Activities
Notifications:     UserNotifications Framework
Testing:           XCTest + Swift Testing
```

### Dependencies
- **Native Only:** No third-party dependencies
- All functionality built using Apple frameworks

### Project Configuration
```
Organization Identifier:  com.mathias
Bundle Identifier:        com.mathias.HapticTimer
Team:                     Mathias Jaeger-Pedersen
Storage:                  SwiftData
Testing:                  Swift Testing with XCTest UI Tests
```

---

## App Architecture

### Navigation Structure
```
App Root (TabView)
│
├── Main Timer Tab (Primary View)
│   ├── Duration Picker (When Timer Stopped)
│   ├── Circle Progress View (Active Timer)
│   ├── Haptic Points Interface
│   ├── Timer Controls (Start/Pause/Reset)
│   └── Save Button (Premium)
│
└── Saved Timers Tab (Premium Only)
    ├── Paywall (Free Users)
    └── Configuration List (Premium Users)
        ├── Configuration Detail View
        └── Delete/Edit Actions
```

### File Structure
```
HapticTimer/
├── HapticTimerApp.swift           # App entry point
├── Models/
│   ├── TimerConfiguration.swift   # SwiftData model for saved timers
│   ├── HapticPoint.swift          # Model for haptic alert points
│   ├── HapticPattern.swift        # Enum for pattern types
│   └── PurchaseState.swift        # Premium status model
│
├── ViewModels/
│   ├── TimerViewModel.swift       # Main timer logic and state
│   ├── HapticViewModel.swift      # Haptic pattern management
│   ├── SavedTimersViewModel.swift # Configuration CRUD operations
│   └── PurchaseViewModel.swift    # StoreKit 2 purchase logic
│
├── Views/
│   ├── MainTimerView.swift        # Primary timer interface
│   ├── Components/
│   │   ├── CircleProgressView.swift      # Animated circle timer
│   │   ├── HapticPointView.swift         # Draggable point on circle
│   │   ├── DurationPickerView.swift      # Time input wheel
│   │   ├── TimerControlsView.swift       # Start/Pause/Reset buttons
│   │   └── PatternSelectorView.swift     # Haptic pattern chooser
│   ├── SavedTimersView.swift      # Configuration list
│   ├── ConfigurationRowView.swift # List item for saved timer
│   ├── PaywallView.swift          # Premium upgrade screen
│   └── Sheets/
│       ├── SaveTimerSheet.swift          # Name and save new config
│       └── ColorPickerSheet.swift        # Premium color selection
│
├── Services/
│   ├── HapticService.swift        # Core Haptics implementation
│   ├── TimerService.swift         # Timer engine and background tasks
│   ├── PurchaseService.swift      # StoreKit 2 wrapper
│   └── NotificationService.swift  # Local notifications and Live Activities
│
├── Utilities/
│   ├── Constants.swift            # App-wide constants
│   ├── Extensions.swift           # Swift extensions
│   └── ColorPalette.swift         # Premium color definitions
│
└── Resources/
    ├── Assets.xcassets
    └── HapticPatterns/
        └── (AHAP files if using pre-composed patterns)
```

### Design Patterns

#### MVVM Architecture
- **Models:** SwiftData entities and value types
- **Views:** SwiftUI views (declarative UI)
- **ViewModels:** `@Observable` classes managing state and business logic

#### Dependency Injection
- Services injected into ViewModels via initializers
- Environment objects for app-wide state (purchase status)

#### Publisher Pattern
- Use Combine publishers for timer updates
- Real-time circle progress updates via `@Published` properties

---

## Core Features

### 1. Timer Duration Input

#### Implementation Details

**Tap-to-Edit Interface:**
- Time is displayed in the center of the circle
- When timer is stopped, "tap to edit" hint appears below time
- Tapping the time opens a bottom sheet with picker wheels
- Sheet presents with `.presentationDetents([.height(350)])`

**Picker Sheet:**
```swift
// Bottom sheet with time picker
NavigationStack {
    VStack {
        Text("Set Duration")

        HStack {
            VStack {
                Text("Hours")
                Picker("Hours", selection: $hours) {
                    ForEach(0..<24) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.wheel)
            }

            VStack {
                Text("Minutes")
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .pickerStyle(.wheel)
            }

            VStack {
                Text("Seconds")
                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .pickerStyle(.wheel)
            }
        }

        Button("Done") { dismiss() }
    }
}
```

**Duration Constraints:**
- Minimum: 00:00:30 (30 seconds)
- Maximum: 23:59:59 (nearly 24 hours)
- Validation on start - show alert if invalid

**State Management:**
- Picker only accessible when timer is stopped (button disabled when running)
- Sheet dismissed when "Done" tapped
- Preserves last set duration on reset

---

### 2. Circular Progress Display

#### Visual Design Specifications

**Circle Dimensions:**
- Diameter: 280pt (standard), 320pt (larger iPhones)
- Stroke width: 20pt
- Position: Vertically centered

**Full Circle Design:**
```
         ───
       /     \
      /       \
     |  10:00  |  ← Time centered
     | tap edit|  ← Hint when stopped
      \       /
       \_____/
```

**Time Display:**
- Centered inside the circle
- Font: SF Pro Rounded, Bold, 48pt
- Color: White (#FFFFFF)
- "tap to edit" hint: 12pt, white 50% opacity (only when stopped)
- Tappable to open time picker sheet

**Progress Fill:**
- Full circle (360°) track visible
- Progress drains clockwise from 12 o'clock position
- Smooth animation (60fps target)
- **Free:** Orange fill (#FF8C42) on dark gray track (#2C2C2E)
- **Premium:** User-selected color with same track

**Implementation Notes:**
```swift
ZStack {
    // Background track (full circle)
    Circle()
        .stroke(Constants.Colors.trackColor,
                style: StrokeStyle(lineWidth: 20, lineCap: .round))

    // Progress fill (drains clockwise from top)
    Circle()
        .trim(from: 0, to: progress) // progress = 0.0 to 1.0
        .stroke(selectedColor,
                style: StrokeStyle(lineWidth: 20, lineCap: .round))
        .rotationEffect(.degrees(-90)) // Start at top
        .animation(.linear(duration: 0.1), value: progress)

    // Time display (center, tappable)
    Button(action: showTimePicker) {
        VStack {
            Text(remainingTime.formattedTime())
                .font(.system(size: 48, weight: .bold, design: .rounded))
            if !isTimerRunning {
                Text("tap to edit")
                    .font(.system(size: 12))
                    .opacity(0.5)
            }
        }
    }
    .disabled(isTimerRunning)
}
```

---

### 3. Haptic Point System

#### Point Lifecycle

**Adding Points:**
1. User taps "Add Vibration Point" button below circle
2. **Free limit check:** If user has 3 points already → show paywall
3. **Premium limit check:** If user has 5 points already → disable button (show "Max points reached")
4. New point appears at random position on circle
5. Random position calculation:
   ```swift
   let randomMinutes = Int.random(in: 1...maxMinutes)
   let randomSeconds = [0, 30].randomElement()!
   let totalSeconds = (randomMinutes * 60) + randomSeconds
   ```

**Point Constraints:**
- Minimum spacing: 30 seconds (same as snap interval)
- Cannot overlap - check collision before placement
- Must be at least 30 seconds before timer end (unless it's the 0:00 point)

#### Point Interaction Modes

**Tap to Edit Pattern:**
```
User Action: Single tap on point
Result:      PatternSelectorView sheet appears
Sheet Contains:
  - List of 4-6 haptic patterns
  - Each pattern has name + preview button
  - Current selection highlighted
  - Tap to select, tap speaker icon to preview
```

**Hold and Drag to Adjust Time:**
```
User Action: Long press (0.3s) + drag
Visual Feedback:
  - Point enlarges slightly (scale 1.2x)
  - Drag preview label appears near point showing time
  - Example: "5:00" or "2:30"
  - Point follows finger along circle perimeter

Behavior:
  - Only moves along circle edge (radial constraint)
  - Snaps to 30-second intervals
    * 10:00, 9:30, 9:00, 8:30, ..., 0:30, 0:00
  - Cannot pass other points (collision detection)
  - Haptic feedback when snapping to new interval
  - Release to commit new position
```

**Snap-to Interval Logic:**
```swift
func snapToInterval(_ totalSeconds: Int) -> Int {
    let thirtySecondIntervals = totalSeconds / 30
    return thirtySecondIntervals * 30
}

// Example:
snapToInterval(320) → 300 (5:00)
snapToInterval(295) → 270 (4:30)
```

**Collision Prevention:**
```swift
func canPlacePoint(at targetSeconds: Int, excluding pointID: UUID?) -> Bool {
    let existingPoints = hapticPoints.filter { $0.id != pointID }
    return !existingPoints.contains { abs($0.triggerSeconds - targetSeconds) < 30 }
}
```

**Delete Point:**
- Swipe left on point → delete button appears
- Or tap point → pattern selector shows "Delete" button
- **Exception:** Cannot delete the 0:00 (completion) point

#### Mandatory Zero Point

**Behavior:**
- Always present - created automatically with timer
- Cannot be deleted or moved
- Position: Always at 0:00 (timer completion)
- Can customize haptic pattern
- Visual: Distinct appearance (e.g., filled circle vs hollow for custom points)

#### Visual Design

**Point Appearance:**
```
Default Points (Custom):     Final Point (0:00):
      ◯                            ◉
  (8pt hollow circle)        (10pt filled circle)
  
When Dragging:               When Selected:
      ◎                            ◉
  (10pt + pulsing)            (10pt + blue ring)
```

**Colors:**
- Custom points: White (#FFFFFF)
- Zero point: Accent color (matches circle color)
- Drag state: 80% opacity
- Selected state: Blue outline (#007AFF)

**Label Display While Dragging:**
```
    ┌─────────┐
    │  5:00   │ ← Floating label
    └────┬────┘
         │
         ◎ ← Point being dragged
```

---

### 4. Haptic Pattern Library

#### Pattern Definitions

Create 6 distinct haptic patterns using Core Haptics API. Each pattern should be **significantly different** in feel so users can distinguish them without looking.

**Pattern 1: "Pulse"**
```swift
// Single strong pulse
Duration: 0.5 seconds
Events:
  - Haptic (intensity: 1.0, sharpness: 0.5, time: 0.0, duration: 0.5)
```
**Feel:** One strong, smooth bump. Like a heartbeat thump.

**Pattern 2: "Heartbeat"**
```swift
// Two quick thumps (lub-dub)
Duration: 1.0 seconds
Events:
  - Haptic (intensity: 0.8, sharpness: 0.6, time: 0.0, duration: 0.15)
  - Haptic (intensity: 1.0, sharpness: 0.7, time: 0.3, duration: 0.2)
```
**Feel:** Lub-dub rhythm, like a heartbeat.

**Pattern 3: "Wave"**
```swift
// Rising then falling intensity
Duration: 2.0 seconds
Events:
  - Haptic with parameter curve (intensity ramps 0.3 → 1.0 → 0.3)
  - Smooth continuous haptic with intensity envelope
```
**Feel:** Ocean wave - builds up, crashes, fades away.

**Pattern 4: "Staccato"**
```swift
// Four quick sharp taps
Duration: 1.2 seconds
Events:
  - Haptic (intensity: 0.8, sharpness: 1.0, time: 0.0, duration: 0.1)
  - Haptic (intensity: 0.8, sharpness: 1.0, time: 0.3, duration: 0.1)
  - Haptic (intensity: 0.8, sharpness: 1.0, time: 0.6, duration: 0.1)
  - Haptic (intensity: 0.8, sharpness: 1.0, time: 0.9, duration: 0.1)
```
**Feel:** Tap-tap-tap-tap. Sharp, distinct, rhythmic.

**Pattern 5: "Rolling"**
```swift
// Continuous rumble with slight variation
Duration: 2.5 seconds
Events:
  - Continuous haptic (intensity: 0.6-0.8, sharpness: 0.3)
  - Small random variations in intensity throughout
```
**Feel:** Like a phone on vibrate mode, extended rumble.

**Pattern 6: "Alert"**
```swift
// Three medium pulses with spacing
Duration: 2.0 seconds
Events:
  - Haptic (intensity: 0.7, sharpness: 0.5, time: 0.0, duration: 0.3)
  - Haptic (intensity: 0.7, sharpness: 0.5, time: 0.6, duration: 0.3)
  - Haptic (intensity: 0.7, sharpness: 0.5, time: 1.2, duration: 0.3)
```
**Feel:** Bump... bump... bump. Insistent but not aggressive.

#### Pattern Selection UI

**Pattern Selector Sheet:**
```
┌────────────────────────────────────┐
│  Choose Haptic Pattern             │
├────────────────────────────────────┤
│  ◉ Pulse              [▶️]         │  ← Currently selected
│  ○ Heartbeat          [▶️]         │
│  ○ Wave               [▶️]         │
│  ○ Staccato           [▶️]         │
│  ○ Rolling            [▶️]         │
│  ○ Alert              [▶️]         │
├────────────────────────────────────┤
│  [Delete Point]        [Done]      │
└────────────────────────────────────┘
```

**Interaction:**
- Tap pattern name → Selects pattern
- Tap [▶️] button → Previews pattern immediately (plays haptic)
- Selected pattern marked with filled radio button
- "Done" button closes sheet and saves selection
- "Delete Point" only shows for custom points (not 0:00 point)

#### Implementation with Core Haptics

**Service Structure:**
```swift
class HapticService {
    private var engine: CHHapticEngine?
    
    func initialize() throws {
        // Create and start haptic engine
        engine = try CHHapticEngine()
        try engine?.start()
    }
    
    func playPattern(_ pattern: HapticPattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // Device doesn't support haptics
            return
        }
        
        let events = createEventsFor(pattern: pattern)
        let hapticPattern = try? CHHapticPattern(events: events, parameters: [])
        let player = try? engine?.makePlayer(with: hapticPattern!)
        try? player?.start(atTime: 0)
    }
    
    private func createEventsFor(pattern: HapticPattern) -> [CHHapticEvent] {
        // Return appropriate events based on pattern type
    }
}
```

**Auto-Dismiss Behavior:**
- Patterns play for 0.5-2.5 seconds
- No user interaction required to stop
- Timer continues running during haptic playback
- Multiple patterns can be queued if user drags through intervals quickly

---

### 5. Timer Controls

#### Button States & Logic

**Start Button:**
```
State: Timer stopped
Display: Large circular "Start" button below circle
Action: Begins countdown
Validation:
  - Duration must be > 0
  - At least one haptic point must exist
Transition: Morphs into Pause + Reset buttons
```

**Pause Button:**
```
State: Timer running
Display: "Pause" button (replaces Start)
Action: Freezes countdown at current time
State Preservation: 
  - Maintains remaining time
  - Maintains circle progress
  - All haptic points preserved
Transition: Changes to "Resume" button
```

**Resume Button:**
```
State: Timer paused
Display: "Resume" button (same position as Pause)
Action: Continues countdown from paused time
Behavior: Identical to Start (just continues from current time)
Transition: Changes back to "Pause" button
```

**Reset Button:**
```
State: Timer running OR paused
Display: Secondary button next to Pause/Resume
Style: Outlined/secondary style
Action: 
  - Stops countdown
  - Resets to initial duration
  - Resets circle to full
  - Preserves haptic points and patterns
Confirmation: Optional "Are you sure?" for long timers (>30 min)
```

**Button Layout:**
```
Timer Stopped:          Timer Running:          Timer Paused:
                                                
                        ┌────────┐ ┌────────┐  ┌────────┐ ┌────────┐
  ┌────────────┐       │ Pause  │ │ Reset  │  │ Resume │ │ Reset  │
  │   Start    │       └────────┘ └────────┘  └────────┘ └────────┘
  └────────────┘
```

#### State Machine

```
States:
  - idle (stopped, not started)
  - running (counting down)
  - paused (stopped mid-countdown)
  - completed (reached 0:00)

Transitions:
  idle → running:     Start button
  running → paused:   Pause button
  paused → running:   Resume button
  running → idle:     Reset button
  paused → idle:      Reset button
  running → completed: Timer reaches 0:00
  completed → idle:   Auto-reset after 3 seconds
```

---

### 6. Saved Timer Configurations

#### Data Persistence (SwiftData)

**TimerConfiguration Model:**
```swift
@Model
class TimerConfiguration {
    var id: UUID
    var name: String
    var durationSeconds: Int
    var circleColor: String // Hex color code
    var createdAt: Date
    var lastUsedAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade)
    var hapticPoints: [HapticPoint]
    
    init(name: String, durationSeconds: Int, circleColor: String) {
        self.id = UUID()
        self.name = name
        self.durationSeconds = durationSeconds
        self.circleColor = circleColor
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.hapticPoints = []
    }
}
```

**HapticPoint Model:**
```swift
@Model
class HapticPoint {
    var id: UUID
    var triggerSeconds: Int // Time before end (e.g., 300 = 5 min before end)
    var pattern: String // HapticPattern enum raw value
    var isZeroPoint: Bool // True for the mandatory 0:00 point
    
    init(triggerSeconds: Int, pattern: HapticPattern, isZeroPoint: Bool = false) {
        self.id = UUID()
        self.triggerSeconds = triggerSeconds
        self.pattern = pattern.rawValue
        self.isZeroPoint = isZeroPoint
    }
}
```

**Storage Limits:**
```swift
enum StorageLimits {
    static let freeConfigSlots = 0      // Free users cannot save
    static let premiumConfigSlots = 15  // Premium users get 15 slots
}
```

#### Saved Timers UI

**List View Design:**
```
┌────────────────────────────────────────┐
│  Saved Timers                     [+]  │ ← New button
├────────────────────────────────────────┤
│  ● Workout HIIT            20:00      │ ← Color dot
│    5:00, 2:00, 0:00                   │
├────────────────────────────────────────┤
│  ● Meditation              15:00      │
│    10:00, 5:00, 0:00                  │
├────────────────────────────────────────┤
│  ● Study Session           50:00      │
│    10:00, 5:00, 2:00, 0:00            │
└────────────────────────────────────────┘
```

**List Item Components:**
- Color indicator (circle/dot) in configured color
- Configuration name (bold, 17pt)
- Duration display (gray, 15pt)
- Haptic points summary (gray, 13pt)
- Swipe actions: Delete (red)

**Empty State:**
```
For Premium Users:
  ┌────────────────────────────────┐
  │     No Saved Timers Yet        │
  │                                │
  │  Tap + to save your first      │
  │     timer configuration        │
  └────────────────────────────────┘

For Free Users:
  [Show Paywall View instead of list]
```

#### Save Flow

**"Save Timer" Button:**
- Location: Top right of Main Timer screen
- Only visible for premium users
- Tapped: Shows save sheet

**Save Sheet UI:**
```
┌────────────────────────────────────────┐
│  Save Timer Configuration              │
├────────────────────────────────────────┤
│  Name:                                 │
│  ┌──────────────────────────────────┐ │
│  │ [Text Field]                     │ │
│  └──────────────────────────────────┘ │
│                                        │
│  Duration: 10:00                       │
│  Haptic Points: 3                      │
│  Color: ● Orange                       │
│                                        │
│  ┌──────────────┐  ┌──────────────┐  │
│  │   Cancel     │  │     Save     │  │
│  └──────────────┘  └──────────────┘  │
└────────────────────────────────────────┘
```

**Validation:**
- Name required (1-30 characters)
- Check if 15 slot limit reached → show error
- Duplicate names allowed (append timestamp if needed)

**Load Configuration:**
1. User taps configuration in list
2. App loads:
   - Duration → updates picker
   - Haptic points → recreates all points with patterns
   - Circle color → updates circle stroke color
3. Automatically dismiss list and return to Main Timer view
4. Timer remains stopped until user presses Start

---

### 7. Premium Features & Monetization

#### In-App Purchase Configuration

**Product Details:**
```swift
enum Products {
    static let premiumID = "com.mathias.haptictimer.premium"
    static let premiumPrice = "$4.99"
}
```

**Product Type:** Non-consumable (one-time purchase)

**StoreKit 2 Implementation:**

**Product.storekit Configuration File:**
```json
{
  "identifier": "com.mathias.haptictimer.premium",
  "type": "non-consumable",
  "displayName": "HapticTimer Premium",
  "description": "Unlock unlimited customization with 5 haptic points, 15 saved configurations, and 10 beautiful colors.",
  "price": 4.99,
  "locale": "en_US"
}
```

**Purchase Manager:**
```swift
@Observable
class PurchaseManager {
    var isPremium: Bool = false
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await checkPurchaseStatus()
        }
    }
    
    func checkPurchaseStatus() async {
        // Check if user has active entitlement
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Products.premiumID {
                isPremium = true
                return
            }
        }
        isPremium = false
    }
    
    func purchasePremium() async throws {
        let product = try await Product.products(for: [Products.premiumID]).first
        guard let product else { throw PurchaseError.productNotFound }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isPremium = true
            }
        case .userCancelled:
            throw PurchaseError.cancelled
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await checkPurchaseStatus()
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.checkPurchaseStatus()
                }
            }
        }
    }
}
```

#### Feature Gating Logic

**Haptic Point Limit Check:**
```swift
func canAddHapticPoint() -> Bool {
    let currentPoints = hapticPoints.filter { !$0.isZeroPoint }.count
    let maxPoints = purchaseManager.isPremium ? 5 : 3
    return currentPoints < maxPoints
}

// When user taps "Add Point"
if !canAddHapticPoint() {
    if !purchaseManager.isPremium {
        showPaywall()
    } else {
        showMaxPointsAlert()
    }
    return
}
```

**Color Selection Check:**
```swift
// In color picker view
if !purchaseManager.isPremium {
    // Disable all colors except orange
    // Show lock icons on premium colors
    // Tapping locked color shows paywall
}
```

**Save Configuration Check:**
```swift
// When user taps "Save"
if !purchaseManager.isPremium {
    showPaywall()
    return
}

// Additional check for premium users
let currentConfigCount = savedConfigurations.count
if currentConfigCount >= 15 {
    showAlert("Maximum 15 configurations reached. Delete one to save a new timer.")
    return
}
```

**Saved Timers Tab Access:**
```swift
// In TabView
if selectedTab == .savedTimers && !purchaseManager.isPremium {
    PaywallView()
} else {
    SavedTimersView()
}
```

#### Paywall UI Design

**Paywall Screen:**
```
┌────────────────────────────────────────┐
│              ⭐ Premium                 │
│                                        │
│  Unlock the full HapticTimer experience│
│                                        │
├────────────────────────────────────────┤
│  ✓  5 custom haptic points             │
│      (vs 3 in free)                    │
│                                        │
│  ✓  Save up to 15 timer configs        │
│      Create presets for every need     │
│                                        │
│  ✓  10 beautiful circle colors         │
│      Personalize your timer            │
│                                        │
│  ✓  One-time payment                   │
│      No subscription. Pay once, own it │
├────────────────────────────────────────┤
│                                        │
│     ┌──────────────────────────────┐  │
│     │  Upgrade for $4.99           │  │
│     └──────────────────────────────┘  │
│                                        │
│           Restore Purchase             │
│                                        │
│               [Close]                  │
└────────────────────────────────────────┘
```

**Paywall Presentation Logic:**
```swift
enum PaywallTrigger {
    case addingFourthPoint
    case attemptingSave
    case selectingPremiumColor
    case accessingSavedTimersTab
}

func showPaywall(trigger: PaywallTrigger) {
    // Track which action triggered paywall for analytics
    // Show modal sheet with paywall
    isShowingPaywall = true
    paywallTrigger = trigger
}
```

**Purchase Flow:**
1. User taps "Upgrade for $4.99"
2. Show loading indicator
3. Call `purchaseManager.purchasePremium()`
4. On success:
   - Show success animation/checkmark
   - Dismiss paywall automatically
   - Unlock premium features immediately
   - If triggered by specific action (e.g., adding point), complete that action
5. On failure:
   - Show error alert with retry option
   - Keep paywall open

**Restore Purchase Flow:**
1. User taps "Restore Purchase"
2. Show loading indicator
3. Call `purchaseManager.restorePurchases()`
4. On success:
   - Show "Purchase restored!" message
   - Dismiss paywall
   - Unlock features
5. On failure or no purchase found:
   - Show "No previous purchase found" message

---

### 8. Background Execution & Lock Screen

#### Background Timer Continuation

**Requirements:**
- Timer must continue counting down when app is backgrounded
- Haptic alerts must fire at correct times even when app is closed
- Lock screen must show live countdown

**Implementation Approach:**

**Option 1: Background Tasks (Recommended)**
```swift
import BackgroundTasks

// Register background task
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.mathias.haptictimer.refresh",
    using: nil
) { task in
    self.handleTimerUpdate(task: task as! BGAppRefreshTask)
}

// Schedule when timer starts
func scheduleBackgroundRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.mathias.haptictimer.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Check every minute
    try? BGTaskScheduler.shared.submit(request)
}
```

**Option 2: Local Notifications + Time Calculation**
```swift
// When timer starts, schedule all haptic notifications
func scheduleHapticNotifications() {
    for point in hapticPoints {
        let notification = UNMutableNotificationContent()
        notification.sound = .none // Silent notification
        notification.interruptionLevel = .timeSensitive
        
        let triggerDate = timerEndDate.addingTimeInterval(-TimeInterval(point.triggerSeconds))
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "haptic-\(point.id)",
            content: notification,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

**Haptic Delivery in Background:**
```swift
// Use UNNotificationServiceExtension to trigger haptics
class NotificationService: UNNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        // When notification arrives, trigger haptic
        let pointID = extractPointID(from: request.identifier)
        let pattern = lookupPattern(for: pointID)
        
        HapticService.shared.playPattern(pattern)
        
        // Complete notification (silent, so user doesn't see banner)
        contentHandler(request.content)
    }
}
```

#### Live Activities & Dynamic Island

**Live Activity Display:**
```
┌─────────────────────────────────────┐
│  HapticTimer                   ⏱️   │
│                                     │
│  ████████░░░░░░░░░░░  8:32         │ ← Progress bar + time
│                                     │
│  Next vibration: 5:00               │
└─────────────────────────────────────┘
```

**Dynamic Island (iPhone 14 Pro+):**
```
Compact:   ⏱️ 8:32

Expanded:  
┌──────────────────┐
│   HapticTimer    │
│                  │
│   ████░░░░  8:32 │
│                  │
│   Next: 5:00     │
└──────────────────┘
```

**Implementation:**
```swift
import ActivityKit

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var nextHapticSeconds: Int?
    }
    
    var timerName: String
    var totalDuration: Int
}

// Start Live Activity when timer begins
func startLiveActivity() {
    let attributes = TimerActivityAttributes(
        timerName: currentConfig?.name ?? "Timer",
        totalDuration: totalDurationSeconds
    )
    
    let initialState = TimerActivityAttributes.ContentState(
        remainingSeconds: remainingSeconds,
        nextHapticSeconds: nextHapticPoint?.triggerSeconds
    )
    
    activity = try? Activity<TimerActivityAttributes>.request(
        attributes: attributes,
        contentState: initialState
    )
}

// Update every second
func updateLiveActivity() {
    Task {
        let updatedState = TimerActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            nextHapticSeconds: nextHapticPoint?.triggerSeconds
        )
        await activity?.update(using: updatedState)
    }
}

// End when timer completes
func endLiveActivity() {
    Task {
        await activity?.end(dismissalPolicy: .immediate)
    }
}
```

#### Lock Screen Integration

**Requirements:**
- Show timer countdown on lock screen
- Tapping notification opens app to active timer
- Haptics play even when phone is locked

**Implementation:**
```swift
// Request notification permissions on first launch
func requestNotificationPermissions() async {
    let center = UNUserNotificationCenter.current()
    try? await center.requestAuthorization(options: [.alert, .sound, .badge])
}

// Create rich notification for timer completion
func scheduleCompletionNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Timer Complete"
    content.body = currentConfig?.name ?? "Your timer has finished"
    content.sound = .none // Haptic only, no sound
    content.interruptionLevel = .timeSensitive
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingSeconds, repeats: false)
    let request = UNNotificationRequest(
        identifier: "timer-complete",
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request)
}
```

---

### 9. Color System

#### Free Tier Color

**Default Orange:**
```swift
extension Color {
    static let timerOrange = Color(hex: "FF8C42")
    // RGB: (255, 140, 66)
    // HSB: (24°, 74%, 100%)
}
```

#### Premium Color Palette

**10 Carefully Selected Colors:**

```swift
enum TimerColor: String, CaseIterable, Codable {
    case orange = "FF8C42"   // Default (free)
    case coral = "FF6B6B"    // Warm red
    case rose = "FF7EB3"     // Pink
    case purple = "A78BFA"   // Lavender
    case indigo = "818CF8"   // Blue-purple
    case sky = "38BDF8"      // Bright blue
    case teal = "2DD4BF"     // Cyan
    case mint = "6EE7B7"     // Light green
    case lime = "BEF264"     // Yellow-green
    case amber = "FBBF24"    // Golden yellow
    
    var color: Color {
        Color(hex: self.rawValue)
    }
    
    var isPremium: Bool {
        self != .orange
    }
}
```

**Color Contrast Validation:**
- All colors must have sufficient contrast against dark background (#1C1C1E)
- WCAG AA compliant (contrast ratio > 4.5:1)

**Color Picker UI (Premium):**
```
┌────────────────────────────────────┐
│  Choose Circle Color               │
├────────────────────────────────────┤
│  ●  ●  ●  ●  ●                     │
│  ●  ●  ●  ●  ●                     │
│                                    │
│  [Circles showing all 10 colors]   │
│  Tap to select                     │
│                                    │
│  Currently: ● Coral                │
└────────────────────────────────────┘
```

---

## Data Models

### Complete SwiftData Schema

```swift
import SwiftData

@Model
class TimerConfiguration {
    @Attribute(.unique) var id: UUID
    var name: String
    var durationSeconds: Int
    var circleColorHex: String
    var createdAt: Date
    var lastUsedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \HapticPoint.configuration)
    var hapticPoints: [HapticPoint]
    
    init(name: String, durationSeconds: Int, circleColorHex: String = "FF8C42") {
        self.id = UUID()
        self.name = name
        self.durationSeconds = durationSeconds
        self.circleColorHex = circleColorHex
        self.createdAt = Date()
        self.lastUsedAt = Date()
        self.hapticPoints = []
    }
    
    func updateLastUsed() {
        self.lastUsedAt = Date()
    }
}

@Model
class HapticPoint {
    @Attribute(.unique) var id: UUID
    var triggerSeconds: Int  // Seconds before timer end
    var patternRawValue: String  // HapticPattern enum
    var isZeroPoint: Bool
    var configuration: TimerConfiguration?
    
    init(triggerSeconds: Int, pattern: HapticPattern, isZeroPoint: Bool = false) {
        self.id = UUID()
        self.triggerSeconds = triggerSeconds
        self.patternRawValue = pattern.rawValue
        self.isZeroPoint = isZeroPoint
    }
    
    var pattern: HapticPattern {
        get { HapticPattern(rawValue: patternRawValue) ?? .pulse }
        set { patternRawValue = newValue.rawValue }
    }
}

enum HapticPattern: String, Codable, CaseIterable {
    case pulse = "pulse"
    case heartbeat = "heartbeat"
    case wave = "wave"
    case staccato = "staccato"
    case rolling = "rolling"
    case alert = "alert"
    
    var displayName: String {
        self.rawValue.capitalized
    }
}

// Purchase state (stored in UserDefaults or Keychain)
class PurchaseState: ObservableObject {
    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }
    
    init() {
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }
}
```

---

## User Interface Specifications

### Design System

#### Typography
```swift
enum Typography {
    static let timeDisplay = Font.system(size: 32, weight: .bold, design: .rounded)
    static let buttonLabel = Font.system(size: 18, weight: .semibold)
    static let timerLabel = Font.system(size: 14, weight: .regular)
    static let configName = Font.system(size: 17, weight: .semibold)
    static let configDetail = Font.system(size: 15, weight: .regular)
}
```

#### Color Palette
```swift
enum AppColors {
    // Backgrounds
    static let background = Color(hex: "1C1C1E")        // Dark gray
    static let secondaryBackground = Color(hex: "2C2C2E") // Slightly lighter
    static let tertiaryBackground = Color(hex: "3A3A3C") // Card backgrounds
    
    // Text
    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.7)
    static let tertiaryText = Color(white: 0.5)
    
    // Accents
    static let accent = Color(hex: "007AFF")            // iOS blue
    static let destructive = Color(hex: "FF3B30")       // iOS red
    static let success = Color(hex: "34C759")           // iOS green
    
    // Circle track
    static let trackColor = Color(hex: "2C2C2E")
}
```

#### Spacing
```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

#### Corner Radius
```swift
enum CornerRadius {
    static let button: CGFloat = 12
    static let card: CGFloat = 16
    static let sheet: CGFloat = 20
}
```

### Responsive Design

**Screen Size Breakpoints:**
```swift
enum DeviceSize {
    case compact    // iPhone SE, Mini
    case standard   // iPhone 13, 14, 15
    case large      // iPhone Pro Max, Plus
    
    var circleSize: CGFloat {
        switch self {
        case .compact: return 260
        case .standard: return 280
        case .large: return 320
        }
    }
    
    var buttonHeight: CGFloat {
        switch self {
        case .compact: return 50
        case .standard: return 56
        case .large: return 60
        }
    }
}
```

**Safe Area Handling:**
- All content respects safe area insets
- Buttons never hidden behind notch or home indicator
- Scrollable content extends to edges with padding

### Accessibility

#### VoiceOver Support
```swift
// All interactive elements must have accessibility labels

Button("Add Vibration Point") {
    addPoint()
}
.accessibilityLabel("Add vibration alert point")
.accessibilityHint("Adds a new haptic feedback point to the timer circle")

// Haptic point
Circle()
    .accessibilityLabel("Haptic alert at \(formatTime(seconds))")
    .accessibilityHint("Double tap to change pattern, hold and drag to adjust time")
    .accessibilityValue("Pattern: \(pattern.displayName)")
```

#### Dynamic Type
- All text scales with user's preferred text size
- Test at largest accessibility sizes
- Layouts should adapt (stack vertically if needed)

#### Reduced Motion
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Disable animations if user prefers reduced motion
.animation(reduceMotion ? .none : .easeInOut, value: progress)
```

#### Haptic Feedback (Ironic but important!)
- Provide visual feedback for haptic actions
- Show haptic pattern names and visual representations
- Allow pattern preview via tap (plays haptic)

---

## Implementation Roadmap

### Phase 1: Core Timer (Days 1-3)

**Day 1: Project Setup & Basic UI**
- [ ] Create Xcode project with correct configuration
- [ ] Set up SwiftData model container
- [ ] Create basic TabView navigation structure
- [ ] Implement duration picker (hours:minutes:seconds)
- [ ] Create basic circle view (no progress yet)
- [ ] Add time display in "cut" arc

**Day 2: Timer Engine**
- [ ] Implement TimerViewModel with state machine
- [ ] Create countdown logic using Combine publishers
- [ ] Add start/pause/resume/reset functionality
- [ ] Connect timer to circle progress animation
- [ ] Ensure accurate timing (test with 1-second updates)

**Day 3: Circle Progress Animation**
- [ ] Implement smooth clockwise drain animation
- [ ] Add "cut" top arc with time display
- [ ] Handle different screen sizes responsively
- [ ] Test performance (60fps target)

### Phase 2: Haptic Points (Days 4-6)

**Day 4: Point Creation & Display**
- [ ] Add "Add Vibration Point" button
- [ ] Implement point placement on circle
- [ ] Create random position generation logic
- [ ] Add mandatory 0:00 point
- [ ] Display points as visible dots on circle

**Day 5: Point Interaction**
- [ ] Implement tap-to-edit pattern functionality
- [ ] Create long-press and drag gesture
- [ ] Add snap-to-30-second-interval logic
- [ ] Implement collision detection
- [ ] Show time label while dragging
- [ ] Add delete functionality (swipe or button)

**Day 6: Haptic Pattern Selector**
- [ ] Create pattern selector sheet UI
- [ ] List all 6 patterns with radio buttons
- [ ] Add preview buttons for each pattern
- [ ] Connect pattern selection to points

### Phase 3: Haptic Engine (Days 7-8)

**Day 7: Core Haptics Implementation**
- [ ] Create HapticService with CHHapticEngine
- [ ] Implement all 6 distinct patterns using Core Haptics API
- [ ] Test patterns on physical device
- [ ] Ensure patterns are significantly different
- [ ] Handle devices without haptic support gracefully

**Day 8: Haptic Integration**
- [ ] Connect timer countdown to haptic triggers
- [ ] Fire haptic patterns at correct times
- [ ] Test timing accuracy with multiple points
- [ ] Ensure haptics work during countdown
- [ ] Add haptic feedback for UI interactions (optional)

### Phase 4: Data Persistence (Days 9-10)

**Day 9: SwiftData Models**
- [ ] Finalize TimerConfiguration model
- [ ] Finalize HapticPoint model
- [ ] Set up model container and context
- [ ] Test CRUD operations with SwiftData

**Day 10: State Persistence**
- [ ] Save last-used timer configuration
- [ ] Restore timer state on app launch
- [ ] Handle edge cases (app crash, force quit)

### Phase 5: Premium Features (Days 11-14)

**Day 11: StoreKit 2 Setup**
- [ ] Create Product.storekit configuration file
- [ ] Add product in App Store Connect
- [ ] Implement PurchaseManager with StoreKit 2
- [ ] Test purchase flow in sandbox environment
- [ ] Implement restore purchases

**Day 12: Paywall UI**
- [ ] Design and implement PaywallView
- [ ] Add premium feature descriptions
- [ ] Connect purchase button to PurchaseManager
- [ ] Add loading states and error handling
- [ ] Test purchase and restoration flows

**Day 13: Feature Gating**
- [ ] Implement haptic point limit checks (3 vs 5)
- [ ] Gate color selection (1 vs 10 colors)
- [ ] Gate saved timers access
- [ ] Gate save functionality
- [ ] Add paywall triggers for each gate

**Day 14: Saved Configurations**
- [ ] Create SavedTimersView with list UI
- [ ] Implement configuration list display
- [ ] Add save/load/delete functionality
- [ ] Create save sheet with name input
- [ ] Enforce 15 configuration limit

### Phase 6: Background & Lock Screen (Days 15-16)

**Day 15: Background Execution**
- [ ] Implement background task registration
- [ ] Schedule haptic notifications for all points
- [ ] Test timer continuation in background
- [ ] Ensure haptics fire when app is backgrounded
- [ ] Handle app termination scenarios

**Day 16: Live Activities**
- [ ] Set up Live Activity attributes and state
- [ ] Create Live Activity UI
- [ ] Implement Dynamic Island views (compact & expanded)
- [ ] Update Live Activity every second
- [ ] Test on physical device with Dynamic Island
- [ ] Add lock screen notification on completion

### Phase 7: Polish & UX (Days 17-19)

**Day 17: Animations & Transitions**
- [ ] Add smooth button transitions
- [ ] Implement circle fill animation
- [ ] Add haptic point drag animations
- [ ] Create tab switch transitions
- [ ] Test at 60fps

**Day 18: Color System**
- [ ] Implement premium color palette (10 colors)
- [ ] Create color picker sheet
- [ ] Lock colors for free users
- [ ] Apply selected color to circle
- [ ] Test contrast against dark background

**Day 19: UI Refinements**
- [ ] Refine button styles and sizes
- [ ] Improve typography hierarchy
- [ ] Add empty states where appropriate
- [ ] Implement error alerts
- [ ] Add confirmation dialogs (e.g., reset timer)

### Phase 8: Accessibility (Day 20)

**Day 20: Accessibility Implementation**
- [ ] Add VoiceOver labels to all elements
- [ ] Test with VoiceOver enabled
- [ ] Implement Dynamic Type support
- [ ] Add reduced motion alternatives
- [ ] Test with accessibility features enabled

### Phase 9: Testing (Days 21-22)

**Day 21: Unit Tests**
- [ ] Write tests for timer logic
- [ ] Test haptic point collision detection
- [ ] Test snap-to-interval logic
- [ ] Test purchase state management
- [ ] Test configuration saving/loading

**Day 22: Integration & Manual Testing**
- [ ] Test full user flows (free & premium)
- [ ] Test on multiple device sizes
- [ ] Test background scenarios
- [ ] Test with poor network (for IAP)
- [ ] Test restore purchases
- [ ] Fix any discovered bugs

### Phase 10: Final Polish (Day 23)

**Day 23: Pre-Launch Checklist**
- [ ] Review all animations for smoothness
- [ ] Verify haptic patterns are distinct
- [ ] Test IAP in TestFlight
- [ ] Proofread all copy and labels
- [ ] Verify App Store Connect configuration
- [ ] Create app icon and screenshots
- [ ] Final QA pass

---

## Testing Requirements

### Manual Test Cases

#### Timer Functionality
1. **Basic countdown**
   - [ ] Timer counts down accurately
   - [ ] Pause and resume work correctly
   - [ ] Reset returns to initial state
   - [ ] Timer stops at 0:00

2. **Edge cases**
   - [ ] Timer with 30 second duration
   - [ ] Timer with 23:59:59 duration
   - [ ] Rapid start/stop/reset
   - [ ] Multiple sequential timers

#### Haptic Points
3. **Point management**
   - [ ] Can add up to limit (3 free, 5 premium)
   - [ ] Cannot add beyond limit
   - [ ] Paywall appears at 4th point (free)
   - [ ] Points appear on circle correctly
   - [ ] Zero point cannot be deleted

4. **Point interaction**
   - [ ] Tap opens pattern selector
   - [ ] Hold and drag moves point
   - [ ] Snaps to 30-second intervals
   - [ ] Cannot overlap other points
   - [ ] Time label shows while dragging
   - [ ] Swipe deletes point

5. **Haptic patterns**
   - [ ] All 6 patterns are distinct
   - [ ] Patterns play on preview
   - [ ] Patterns fire at correct times
   - [ ] Multiple patterns in sequence work
   - [ ] Patterns work in background

#### Premium Features
6. **In-app purchase**
   - [ ] Purchase flow completes successfully
   - [ ] Features unlock immediately
   - [ ] Receipt validation works
   - [ ] Restore purchase works
   - [ ] Purchase persists across app launches

7. **Feature gates**
   - [ ] Free user: 3 point limit enforced
   - [ ] Free user: Cannot access saved timers
   - [ ] Free user: Cannot change colors
   - [ ] Free user: Cannot save configurations
   - [ ] Premium user: All features accessible

8. **Saved configurations**
   - [ ] Can save up to 15 configs
   - [ ] Configurations save all data correctly
   - [ ] Loading config restores all settings
   - [ ] Deleting config works
   - [ ] Cannot exceed 15 config limit

#### Background & Lock Screen
9. **Background execution**
   - [ ] Timer continues in background
   - [ ] Haptics fire when app backgrounded
   - [ ] Haptics fire when phone locked
   - [ ] Lock screen shows countdown
   - [ ] Live Activity updates in real-time
   - [ ] Notification appears on completion

10. **App lifecycle**
    - [ ] State persists after app close
    - [ ] State persists after device restart
    - [ ] Handles low memory warnings
    - [ ] Handles background app refresh disabled

#### UI/UX
11. **Responsive design**
    - [ ] Works on iPhone SE
    - [ ] Works on iPhone 15
    - [ ] Works on iPhone 15 Pro Max
    - [ ] Adapts to landscape (if needed)

12. **Accessibility**
    - [ ] VoiceOver navigation works
    - [ ] All buttons have proper labels
    - [ ] Dynamic Type scaling works
    - [ ] Reduced motion respected

### Automated Tests (XCTest)

```swift
// Example unit tests

class TimerViewModelTests: XCTestCase {
    var viewModel: TimerViewModel!
    
    override func setUp() {
        viewModel = TimerViewModel()
    }
    
    func testTimerCountdown() {
        viewModel.setDuration(seconds: 10)
        viewModel.start()
        
        XCTAssertEqual(viewModel.state, .running)
        
        // Wait and verify countdown
        let expectation = XCTestExpectation(description: "Timer counts down")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertLessThan(self.viewModel.remainingSeconds, 10)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
    
    func testPauseResume() {
        viewModel.setDuration(seconds: 60)
        viewModel.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel.pause()
            let pausedTime = self.viewModel.remainingSeconds
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssertEqual(self.viewModel.remainingSeconds, pausedTime)
                
                self.viewModel.resume()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    XCTAssertLessThan(self.viewModel.remainingSeconds, pausedTime)
                }
            }
        }
    }
    
    func testHapticPointSnapping() {
        let snapped = viewModel.snapToInterval(seconds: 320)
        XCTAssertEqual(snapped, 300) // Should snap to 5:00
        
        let snapped2 = viewModel.snapToInterval(seconds: 295)
        XCTAssertEqual(snapped2, 270) // Should snap to 4:30
    }
    
    func testCollisionDetection() {
        viewModel.addHapticPoint(at: 300) // 5:00
        viewModel.addHapticPoint(at: 120) // 2:00
        
        let canPlace = viewModel.canPlacePoint(at: 300)
        XCTAssertFalse(canPlace) // Already exists
        
        let canPlace2 = viewModel.canPlacePoint(at: 60)
        XCTAssertTrue(canPlace2) // No collision
    }
    
    func testFreeUserPointLimit() {
        viewModel.isPremium = false
        viewModel.addHapticPoint(at: 300)
        viewModel.addHapticPoint(at: 120)
        viewModel.addHapticPoint(at: 60)
        
        XCTAssertEqual(viewModel.hapticPoints.count, 3)
        XCTAssertFalse(viewModel.canAddHapticPoint())
    }
    
    func testPremiumUserPointLimit() {
        viewModel.isPremium = true
        for i in 1...5 {
            viewModel.addHapticPoint(at: i * 60)
        }
        
        XCTAssertEqual(viewModel.hapticPoints.count, 5)
        XCTAssertFalse(viewModel.canAddHapticPoint())
    }
}

class PurchaseManagerTests: XCTestCase {
    func testPurchaseStateRestoration() async {
        let manager = PurchaseManager()
        await manager.checkPurchaseStatus()
        
        // Should match App Store state
        // This test requires StoreKit testing configuration
    }
}
```

---

## Edge Cases & Error Handling

### Edge Cases to Handle

#### Timer Edge Cases
1. **Very short durations (<30 seconds)**
   - Ensure haptic points can be placed
   - Prevent points from being too close together
   - Circle animation should still be smooth

2. **Very long durations (>1 hour)**
   - Battery impact considerations
   - Background refresh limits
   - User might forget timer is running

3. **Rapid interaction**
   - Quickly starting/stopping timer
   - Dragging points rapidly
   - Spamming add point button
   - Should be debounced and responsive

4. **Multiple points at similar times**
   - E.g., 5:00 and 4:30
   - Ensure both fire correctly
   - No haptic overlap/interference

#### Background Scenarios
5. **App termination**
   - System kills app due to memory pressure
   - User force-quits app
   - Timer should still complete (via notifications)
   - Haptic notifications should still fire

6. **Background refresh disabled**
   - Show warning to user
   - Explain that haptics may not fire in background
   - Recommend keeping app in foreground

7. **Low battery mode**
   - Background activity restricted
   - Test if haptics still fire
   - Warn user if necessary

#### Purchase Scenarios
8. **Network issues during purchase**
   - Show appropriate error message
   - Allow retry
   - Don't lock user out of app

9. **Purchase pending**
   - Handle "Ask to Buy" for family accounts
   - Show pending state in UI
   - Check transaction state on next launch

10. **Receipt validation failure**
    - Retry validation
    - Fall back to local cache if persistent
    - Don't lock premium features unnecessarily

#### Data Scenarios
11. **SwiftData migration**
    - Future app updates may change models
    - Ensure migration path exists
    - Don't lose user configurations

12. **Storage full**
    - Handle SwiftData save errors
    - Show error to user
    - Suggest deleting old configurations

13. **Corrupted configuration**
    - Invalid durations (e.g., negative)
    - Missing required fields
    - Gracefully skip or reset to default

### Error Handling Patterns

#### User-Facing Errors
```swift
enum TimerError: LocalizedError {
    case invalidDuration
    case maxPointsReached
    case purchaseFailed(underlying: Error)
    case cannotSaveConfiguration
    case storageError
    
    var errorDescription: String? {
        switch self {
        case .invalidDuration:
            return "Please set a duration of at least 30 seconds"
        case .maxPointsReached:
            return "Maximum number of haptic points reached"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .cannotSaveConfiguration:
            return "Cannot save configuration. Maximum 15 configurations allowed."
        case .storageError:
            return "Unable to save. Please check available storage."
        }
    }
}

// Show alerts for errors
func showError(_ error: TimerError) {
    alertTitle = "Error"
    alertMessage = error.errorDescription ?? "An unknown error occurred"
    showingAlert = true
}
```

#### Silent Errors (Logged but not shown)
```swift
// Haptic engine unavailable
if !CHHapticEngine.capabilitiesForHardware().supportsHaptics {
    print("⚠️ Haptics not supported on this device")
    // Continue without haptics, don't block user
}

// Background task scheduling failed
do {
    try BGTaskScheduler.shared.submit(request)
} catch {
    print("⚠️ Failed to schedule background task: \(error)")
    // App will rely on notifications instead
}
```

#### Graceful Degradation
```swift
// If Live Activities unavailable (iOS <16.1)
if #available(iOS 16.1, *) {
    startLiveActivity()
} else {
    // Fall back to regular notifications
    scheduleNotifications()
}

// If haptic engine fails to start
do {
    try hapticEngine.start()
} catch {
    print("Haptic engine failed to start")
    hapticEngine = nil // Disable haptics for session
    // App continues to function, just without haptics
}
```

---

## Performance Considerations

### Optimization Targets
- **App launch:** <1 second on device
- **Timer start:** Instant response (<100ms)
- **Circle animation:** 60fps minimum
- **Haptic playback:** <50ms latency
- **Background battery:** <5% drain per hour

### Memory Management
```swift
// Proper cleanup of haptic engine
deinit {
    try? hapticEngine?.stop()
    hapticEngine = nil
}

// Release timer publishers when not needed
func stopTimer() {
    timerCancellable?.cancel()
    timerCancellable = nil
}
```

### Network Usage
- StoreKit transactions only
- No analytics or tracking
- Minimal data usage

---

## Future Enhancements (Post-Launch)

Potential features for v2.0+:

1. **Widget support** - Show active timer on home screen
2. **Apple Watch app** - Control timer from wrist
3. **Siri shortcuts** - "Start my workout timer"
4. **Presets** - Built-in templates (Workout, Meditation, etc.)
5. **Haptic rhythm creator** - Custom pattern designer
6. **Multiple simultaneous timers** - Run 2-3 at once
7. **Interval timer mode** - Repeat cycles (HIIT, Tabata)
8. **Statistics** - Track total timer usage, most-used configs
9. **Sound option** - Add optional sound alerts (still haptic-first)
10. **Themes** - Light mode, custom backgrounds

---

## Submission Checklist

Before submitting to App Store:

### Technical
- [ ] No crashes or hangs
- [ ] Tested on all supported devices
- [ ] Tested on iOS 17.0 minimum
- [ ] Memory leaks checked with Instruments
- [ ] Battery usage acceptable
- [ ] Network usage minimal
- [ ] Haptics work on all compatible devices

### App Store Connect
- [ ] App icon (1024x1024)
- [ ] Screenshots for all device sizes
- [ ] App preview video (optional but recommended)
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] App description and keywords
- [ ] Age rating (4+)
- [ ] In-app purchase configured
- [ ] TestFlight testing completed

### Legal
- [ ] Privacy policy created
- [ ] No tracking without consent
- [ ] Subscription terms (if applicable)
- [ ] StoreKit transaction logging

### Marketing
- [ ] App name: "HapticTimer"
- [ ] Subtitle: "Feel Your Time"
- [ ] Keywords: timer, haptic, vibration, workout, meditation
- [ ] Category: Productivity (or Utilities)

---

## Support & Maintenance

### User Support Channels
- Email: [support email]
- In-app feedback form (optional)
- App Store reviews

### Common User Issues

**Issue: Haptics not firing in background**
- Solution: Check notification permissions, background refresh enabled

**Issue: Purchase not restoring**
- Solution: Ensure signed in with same Apple ID, try "Restore Purchase"

**Issue: Timer not accurate**
- Solution: Background refresh may be limited, keep app active

**Issue: Cannot add more points**
- Solution: Reached limit (3 free, 5 premium), upgrade to premium

---

## Conclusion

This specification provides a complete blueprint for implementing HapticTimer from initial project setup through App Store submission. The app combines innovative haptic feedback patterns with an intuitive circular interface to create a unique timer experience.

**Key Success Factors:**
- Distinct, easily recognizable haptic patterns
- Smooth, polished UI with creative design
- Reliable background execution
- Clear premium value proposition
- Solid technical foundation with SwiftData and StoreKit 2

**Development Timeline:** ~23 days (full-time)  
**Lines of Code Estimate:** ~3,000-4,000 (SwiftUI + supporting code)

This document should be referenced throughout development and updated as implementation details are refined.

---

**Document Version:** 1.0  
**Last Updated:** January 14, 2026  
**Author:** Mathias Jaeger-Pedersen  
**For:** Claude Code Implementation
