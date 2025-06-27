# CribScore

A modern iOS app for keeping score in cribbage games, built with SwiftUI and Core Data.

## Features

- **Custom Score Dial Interface**: Intuitive circular dial for selecting points (1-29 range)
- **Dual Player Support**: Track scores for two players with customizable names and colors
- **Game History**: Persistent storage of completed games with Core Data
- **Player Statistics**: Track wins, losses, and average scores
- **Customizable Backgrounds**: Choose from multiple background themes
- **Settings Persistence**: All user preferences are saved using Core Data
- **Responsive Design**: Supports both portrait and landscape orientations
- **Immersive Game Mode**: Full-screen view with circular progress bars

## Background Themes

- **Classic**: Clean white background
- **Felt Green**: Traditional card table felt
- **Midnight Blue**: Dark gradient with subtle star effects
- **Warm Sunset**: Warm gradient from cream to peach
- **Ocean Breeze**: Cool gradient in blue tones
- **Subtle Pattern**: Diagonal line pattern overlay

## Settings

- **Haptic Feedback**: Toggle haptic feedback for dial interactions
- **Sound Effects**: Enable/disable sound feedback
- **Extended Score Indicator**: Show indicator when score exceeds 15
- **Auto-Save Games**: Automatically save completed games
- **Keep Screen On**: Prevent screen from sleeping during games
- **Background Theme**: Choose your preferred visual theme

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Persistent storage for games and settings
- **MVVM Pattern**: Separation of concerns with GameViewModel
- **Custom Components**: Reusable ScoreDialView and CircularScoreProgressView

### Core Data Model

- **Game**: Stores completed games (players, scores, date, duration)
- **PlayerStats**: Cumulative player statistics
- **UserSettings**: Persistent user preferences

### Key Components

- **GameViewModel**: Central game state management and scoring logic
- **ScoreDialView**: Custom circular input control with haptic feedback
- **CircularScoreProgressView**: Animated progress bars for full-screen mode
- **BackgroundStyle**: Configurable background themes with proper contrast

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `Cribble.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device

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

## How to Play

1. Start a new game and enter player names
2. Use the score dial to select points earned in each hand
3. Tap "Add [points]" to apply the score
4. First player to reach 121 points wins
5. Game automatically saves to history when completed

## Development

The app follows iOS best practices:

- Uses `@StateObject` and `@EnvironmentObject` for state management
- Implements proper Core Data relationships and error handling
- Supports both iPhone and iPad (Universal app)
- Transparent navigation and tab bars for seamless background themes
- Haptic feedback for enhanced user experience

## License

This project is available for personal and educational use.
