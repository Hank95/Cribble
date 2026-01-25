# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CribScore is a SwiftUI iOS app for cribbage scorekeeping. It tracks games between two players, persists game history using Core Data, and provides a custom circular score dial interface.

## Build Commands

```bash
# Build for iOS Simulator
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build

# Build for device
xcodebuild -project Cribble.xcodeproj -scheme Cribble -configuration Release build

# Run tests
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' test

# Clean build
xcodebuild -project Cribble.xcodeproj -scheme Cribble clean

# Archive for App Store
xcodebuild -project Cribble.xcodeproj -scheme Cribble -configuration Release -destination 'generic/platform=iOS' -archivePath build/Cribble.xcarchive archive

# Export and upload to App Store Connect
xcodebuild -exportArchive -archivePath build/Cribble.xcarchive -exportPath build/export -exportOptionsPlist build/ExportOptions.plist
```

## Architecture

### Core Data Model
- **Player**: Player identity with name, creation date, and game relationships for league tracking
- **Game**: Stores completed games with Player relationships (winnerPlayer/loserPlayer), scores, date, and duration. Includes computed properties for skunk detection and match points.
- **PlayerStats**: Legacy cumulative player statistics (deprecated, replaced by Player entity)
- **UserSettings**: Persistent user preferences (haptics, keep screen on, background theme, onboarding status)

### Key Components

**GameViewModel** (`ViewModels/GameViewModel.swift`)
- Central game state management
- Handles score tracking, turn management, and win detection (121 points)
- Triggers Core Data saves via PersistenceController

**ScoreDialView** (`Components/ScoreDialView.swift`)
- Custom circular input control for score selection (1-29 range)
- **Tap-to-increment**: Single tap adds +1 point instantly
- **Drag to select**: 360-degree rotational interface for any value
- Separate add/subtract modes (clockwise/counter-clockwise)
- Haptic feedback on value changes (respects `UserSettings.enableHaptics`)
- Snaps to nearest integer values with spring animation
- Uses `GeometryReader` for responsive sizing - adapts to any container frame
- All elements (pointer, ticks, fonts) scale proportionally

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
- Statistics section: Points to league/stats in History
- Help section: Rules and App Tour
- Support section: Donation links
- Reset all settings functionality

**LeagueTableView** (`Views/LeagueTableView.swift`)
- League standings with player rankings sorted by match points
- Shows wins, losses, win percentage, and match point breakdown
- Skunk and double-skunk counts per player

**HeadToHeadView** (`Views/HeadToHeadView.swift`)
- Compare two players' historical record
- Shows wins, losses, skunks, and recent games between selected players
- Player selection via dropdown pickers

**PlayerManagementView** (`Views/PlayerManagementView.swift`)
- Rename players (updates Player entity, games stay linked)
- Merge duplicate players (moves all games to target player)
- Delete players (with confirmation)

**PlayerPickerView** (`Components/PlayerPickerView.swift`)
- Autocomplete player selection for new games
- Case-insensitive search with suggestions
- Option to create new player or select existing

**StatsService** (`Services/StatsService.swift`)
- Statistics computation layer for league and head-to-head data
- PlayerLeagueStats: Aggregates wins, losses, skunks, match points
- HeadToHeadStats: Computes record between two specific players

### Responsive Layout System

**MainGameView** uses a comprehensive responsive layout system:
- `GeometryReader` detects available screen size
- `isCompact` threshold (`height < 700` for portrait, `height < 400` for landscape)
- Device-specific sizing: `UIDevice.current.userInterfaceIdiom == .pad`
- Separate portrait and landscape layouts with orientation detection
- Dial sizes calculated as percentage of available height with min/max clamping
- Adaptive spacing, fonts, and padding based on screen constraints

**Small Screen Support** (iPhone SE, iPhone 16e):
- Reduced dial sizes and tighter spacing
- ScrollView wrappers to prevent content clipping
- Adaptive LazyVGrid layouts in NewGameSetupView and OnboardingView

### Data Flow
1. User interacts with ScoreDialView to select points (tap for +1, drag for any value)
2. GameViewModel receives score updates and manages game state
3. On game completion, PersistenceController saves to Core Data with Player relationships
4. HistoryView fetches and displays saved games via @FetchRequest
5. StatsService computes league standings and head-to-head records from Game relationships

### Scoring System
- **Win**: 1 match point (opponent reaches 0-90 points)
- **Skunk**: 2 match points (opponent has less than 91 points)
- **Double Skunk**: 3 match points (opponent has less than 61 points)
- League table ranks players by total match points

## Development Requirements

- iOS Deployment Target: 17.0
- Swift Version: 5.0
- Xcode 15.0+
- No external dependencies - uses only SwiftUI and Core Data
- Supports iPhone and iPad (Universal app)

## iOS 26 Compatibility

The codebase uses modern SwiftUI APIs compatible with iOS 26:
- `NavigationStack` (not deprecated `NavigationView`)
- Two-parameter `onChange(of:) { oldValue, newValue in }` syntax
- `@Environment(\.dismiss)` (not deprecated `presentationMode`)

## Version History

**1.2** (Current)
- **Tap-to-increment**: Quick tap on score dial to add +1 point instantly
- **League Table**: Track player rankings with wins, losses, and match points
- **Head-to-Head Records**: Compare your record against any opponent
- **Skunk Tracking**: Earn bonus match points for skunks (2 pts) and double skunks (3 pts)
- **Player Management**: Rename, merge, or delete players from Game History
- **Player Autocomplete**: Quick player selection when starting new games
- **Enhanced Game Over Screen**: Shows skunk status and match points earned
- **Updated Onboarding**: New tutorial content covering league and statistics features

**1.1**
- Responsive layouts for all screen sizes (iPhone SE through iPad Pro)
- ScoreDialView now uses GeometryReader for proper frame sizing
- Fixed UI spacing issues in portrait and landscape orientations
- iOS 26 API compatibility updates
- Dynamic version display in Settings

**1.0**
- Initial release