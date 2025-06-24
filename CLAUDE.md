# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cribble is a SwiftUI iOS app for cribbage scorekeeping. It tracks games between two players, persists game history using Core Data, and provides a custom circular score dial interface.

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

### Key Components

**GameViewModel** (`ViewModels/GameViewModel.swift`)
- Central game state management
- Handles score tracking, turn management, and win detection (121 points)
- Triggers Core Data saves via PersistenceController

**ScoreDialView** (`Components/ScoreDialView.swift`)
- Custom circular input control for score selection (1-29 range)
- Dial shows markings 1-15, but scrolling past 15 continues to 16-29
- Implements drag gestures with haptic feedback
- Snaps to integer values
- Shows "Extended" indicator when score > 15

**Navigation Structure**
- `ContentView` → `MainTabView` → tabs for Game and History
- Game tab shows `MainGameView` with active game
- History tab shows `HistoryView` with completed games list
- `FullScreenGameView` accessible via viewfinder button - immersive mode with circular progress bars

**CircularScoreProgressView** (`Components/CircularScoreProgressView.swift`)
- Creates rounded rectangle progress bars that loop around screen edges
- Player 1 (outer track, blue) and Player 2 (inner track, orange)
- Animated progress from 0 to 121 points
- Used in full-screen game mode

### Data Flow
1. User interacts with ScoreDialView to select points
2. GameViewModel receives score updates and manages game state
3. On game completion, PersistenceController saves to Core Data
4. HistoryView fetches and displays saved games via @FetchRequest

## Development Requirements

- iOS Deployment Target: 18.5
- Swift Version: 5.0
- No external dependencies - uses only SwiftUI and Core Data
- Supports iPhone and iPad (Universal app)