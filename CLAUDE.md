# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CribScore is a SwiftUI iOS app for cribbage scorekeeping. It tracks games between two players, persists game history using Core Data, and provides a custom circular score dial interface.

## Build Commands

```bash
# Build for iOS Simulator
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' build

# Build for device
xcodebuild -project Cribble.xcodeproj -scheme Cribble -configuration Release build

# Run tests
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test

# Clean build
xcodebuild -project Cribble.xcodeproj -scheme Cribble clean
```

## Architecture

### Core Data Model
- **Game**: Stores completed games with winner/loser names, scores, date, and duration
- **PlayerStats**: Tracks cumulative player statistics (games played/won/lost, average score)
- **UserSettings**: Persistent user preferences (haptics, keep screen on, background theme, onboarding status)

### Key Components

**GameViewModel** (`ViewModels/GameViewModel.swift`)
- Central game state management
- Handles score tracking, turn management, and win detection (121 points)
- Triggers Core Data saves via PersistenceController

**ScoreDialView** (`Components/ScoreDialView.swift`)
- Custom circular input control for score selection (1-29 range)
- 360-degree rotational interface with drag gestures
- Separate add/subtract modes (clockwise/counter-clockwise)
- Haptic feedback on value changes (respects `UserSettings.enableHaptics`)
- Snaps to nearest integer values with spring animation

**Navigation Structure**
- `ContentView` → `MainGameView` with active game and `ScoringOverlayView`
- Toolbar provides access to `HistoryView`, `SettingsView`, and `NewGameSetupView`
- `OnboardingView` shown as full-screen cover on first launch (can be replayed from Settings)
- `CribbageRulesView` and `DonationView` accessible from Settings

**CircularScoreProgressView** (`Components/CircularScoreProgressView.swift`)
- Creates rounded rectangle progress bars that loop around screen edges
- Player 1 (outer track, blue) and Player 2 (inner track, orange)
- Animated progress from 0 to 121 points with winning animations
- Used in `ScoringOverlayView` overlay on main game screen

**ScoringOverlayView** (`Components/ScoringOverlayView.swift`)
- Floating circular progress indicator overlay
- Shows real-time score progress for both players
- Positioned in corner of MainGameView

**OnboardingView** (`Views/OnboardingView.swift`)
- 4-page interactive tutorial with animated transitions
- Includes interactive score dial demo
- Tracks completion via `UserSettings.hasSeenOnboarding`

**CribbageRulesView** (`Views/CribbageRulesView.swift`)
- Comprehensive cribbage rules reference
- Covers gameplay, scoring, and variations
- Accessible from Settings Help section

**SettingsView** (`Views/SettingsView.swift`)
- Game options: Haptic feedback toggle
- Display: Keep screen on toggle
- Background theme selector (6 themes)
- Help section: Rules and App Tour
- Support section: Donation links
- Reset all settings functionality

### Data Flow
1. User interacts with ScoreDialView to select points
2. GameViewModel receives score updates and manages game state
3. On game completion, PersistenceController saves to Core Data
4. HistoryView fetches and displays saved games via @FetchRequest

## Development Requirements

- iOS Deployment Target: 17.0
- Swift Version: 5.0
- Xcode 15.0+
- No external dependencies - uses only SwiftUI and Core Data
- Supports iPhone and iPad (Universal app)