# CribScore

A modern iOS app for keeping score in cribbage games, built with SwiftUI and Core Data.

**Current Version: 1.2**

### What's New in 1.2

**Faster Scoring**
- Tap the score dial to quickly add +1 point
- Drag for larger values (1-29) like before

**League & Statistics**
- League Table — Track rankings with wins, losses, and match points
- Head-to-Head — Compare your record against any opponent
- Player Management — Rename, merge, or delete players

**Skunk Tracking**
- Earn 2 match points for a skunk (opponent < 91)
- Earn 3 match points for a double skunk (opponent < 61)
- Game over screen now shows skunk status and points earned

**Quality of Life**
- Player autocomplete when starting new games
- Updated tutorial with new features

## Features

### Scoring
- **Custom Score Dial Interface**: Intuitive circular dial for selecting points (1-29 range)
- **Tap to Increment**: Quick tap on the dial to add +1 point instantly
- **Drag to Select**: Drag clockwise to add points, counter-clockwise to subtract
- **Dual Player Support**: Track scores for two players with customizable names and colors
- **Haptic Feedback**: Configurable vibration feedback for dial interactions

### Statistics & League
- **League Table**: Track player rankings with wins, losses, and match points
- **Head-to-Head Records**: Compare your record against any opponent
- **Skunk Tracking**: Earn bonus match points for skunks (2 pts) and double skunks (3 pts)
- **Player Management**: Rename, merge, or delete players from Game History

### Game Features
- **Game History**: Persistent storage of completed games with Core Data
- **Player Autocomplete**: Quick player selection when starting new games
- **Enhanced Game Over Screen**: Shows skunk status and match points earned
- **Circular Score Progress**: Animated progress bars showing game advancement

### Customization
- **Customizable Backgrounds**: Choose from 6 visual background themes
- **Settings Persistence**: All user preferences are saved using Core Data
- **Fully Responsive Design**: Adapts to all screen sizes from iPhone SE to iPad Pro, portrait and landscape

### Help & Learning
- **Interactive Onboarding**: 4-page tutorial with live score dial demo
- **Cribbage Rules Reference**: Comprehensive in-app rules documentation

## Background Themes

- **Classic**: Clean white background
- **Felt Green**: Traditional card table felt
- **Midnight Blue**: Dark gradient with subtle star effects
- **Warm Sunset**: Warm gradient from cream to peach
- **Ocean Breeze**: Cool gradient in blue tones
- **Subtle Pattern**: Diagonal line pattern overlay

## Settings

**Game Options:**
- **Haptic Feedback**: Toggle vibration feedback for dial interactions

**Display:**
- **Keep Screen On**: Prevent screen from sleeping during games
- **Background Theme**: Choose from 6 visual themes

**Help:**
- **Cribbage Rules**: Comprehensive rules reference
- **App Tour**: Replay the onboarding walkthrough

**Support:**
- **Donation Links**: Ko-fi, Buy Me a Coffee, and PayPal options

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Persistent storage for games and settings
- **MVVM Pattern**: Separation of concerns with GameViewModel
- **Custom Components**: Reusable ScoreDialView and CircularScoreProgressView

### Core Data Model

- **Game**: Stores completed games (players, scores, date, duration) with Player relationships
- **Player**: Player identity with name, creation date, and game relationships for league tracking
- **PlayerStats**: Legacy cumulative player statistics (deprecated, replaced by Player entity)
- **UserSettings**: Persistent user preferences (haptics, keep screen on, background theme, onboarding status)

### Key Components

- **GameViewModel**: Central game state management and scoring logic
- **ScoreDialView**: Custom circular input control with tap-to-increment, drag gestures, and haptic feedback
- **CircularScoreProgressView**: Animated progress bars with winning animations
- **ScoringOverlayView**: Floating progress indicator overlay
- **PlayerPickerView**: Autocomplete player selection for new games
- **LeagueTableView**: League standings with rankings and match points
- **HeadToHeadView**: Player comparison statistics
- **PlayerManagementView**: Rename, merge, and delete players
- **StatsService**: Statistics computation layer for league and head-to-head data
- **OnboardingView**: Interactive 4-page tutorial walkthrough with adaptive layouts
- **CribbageRulesView**: Comprehensive rules reference
- **BackgroundStyle**: Configurable background themes with proper contrast
- **MainGameView**: Responsive layouts for portrait/landscape with device-specific sizing

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
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build

# Build for device
xcodebuild -project Cribble.xcodeproj -scheme Cribble -configuration Release build

# Run all tests
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' test

# Run unit tests only (faster, recommended)
xcodebuild -project Cribble.xcodeproj -scheme Cribble -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' test -only-testing:CribbleTests -parallel-testing-enabled NO

# Clean build
xcodebuild -project Cribble.xcodeproj -scheme Cribble clean
```

## How to Play

1. Start a new game and enter player names (existing players auto-complete)
2. Use the score dial to select points:
   - **Tap** the dial to quickly add +1 point
   - **Drag clockwise** to select larger point values (1-29)
   - **Drag counter-clockwise** to subtract points if needed
3. Tap the "Add [points]" button to apply the score
4. First player to reach 121 points wins
5. Game automatically saves to history when completed

### Scoring Bonuses
- **Skunk**: Win while opponent has less than 91 points = 2 match points
- **Double Skunk**: Win while opponent has less than 61 points = 3 match points
- Regular win = 1 match point

### Statistics
Access league standings, head-to-head records, and player management from the **Game History** screen (clock icon in toolbar).

## Development

The app follows iOS best practices:

- Uses `@StateObject` and `@EnvironmentObject` for state management
- Implements proper Core Data relationships and error handling
- Supports both iPhone and iPad (Universal app)
- Transparent navigation and tab bars for seamless background themes
- Haptic feedback for enhanced user experience
- Responsive layouts using `GeometryReader` and device detection
- iOS 26 compatible APIs (`NavigationStack`, modern `onChange` syntax)

## Version History

### 1.2 (Current)
- **Tap to Increment**: Quick tap on the score dial to add +1 point instantly
- **League Table**: Track player rankings with wins, losses, and match points
- **Head-to-Head Records**: Compare your record against any opponent
- **Skunk Tracking**: Earn bonus match points for skunks and double skunks
- **Player Management**: Rename, merge, or delete players
- **Player Autocomplete**: Quick player selection when starting new games
- **Enhanced Game Over Screen**: Shows skunk status and match points earned
- **Updated Onboarding**: New tutorial content covering league and statistics features

### 1.1
- **Responsive Layouts**: Full support for all screen sizes from iPhone SE to iPad Pro
- **Improved ScoreDialView**: Now uses GeometryReader for proper frame sizing on all devices
- **Landscape Mode Fixes**: Proper spacing for player names, dials, and buttons in landscape orientation
- **iOS 26 Compatibility**: Updated to use modern SwiftUI APIs (NavigationStack, new onChange syntax)
- **Dynamic Version Display**: Settings now shows version from app bundle automatically

### 1.0
- Initial release with core cribbage scorekeeping functionality
- Custom score dial interface
- Game history and player statistics
- 6 background themes
- Interactive onboarding tutorial

## License

This project is available for personal and educational use.
