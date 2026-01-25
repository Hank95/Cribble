import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var showingWinAlert = false
    @State private var showingNewGameConfirmation = false
    @State private var showingNewGameSetup = false
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var isLandscape = false
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private var selectedBackground: BackgroundStyle {
        let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
        return BackgroundStyle(rawValue: backgroundValue) ?? .classic
    }

    // MARK: - Responsive Sizing

    /// Returns dial size based on available height and device type
    private func dialSize(for geometry: GeometryProxy) -> CGFloat {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        if isIPad {
            return isLandscape ? 200 : 240
        }

        // For iPhones, calculate based on available height
        let availableHeight = geometry.size.height

        if isLandscape {
            // iPhone landscape is very height-constrained
            // Calculate dial as percentage of height, with room for name above and button below
            let calculatedSize = availableHeight * 0.50
            return min(max(calculatedSize, 80), 140) // Between 80-140pt for iPhone landscape
        } else {
            // Portrait: dial should be ~22% of available height, clamped
            let calculatedSize = availableHeight * 0.22
            return min(max(calculatedSize, 100), 160) // Between 100-160pt
        }
    }

    /// Returns vertical padding based on screen height
    private func verticalPadding(for geometry: GeometryProxy, position: VerticalEdge) -> CGFloat {
        let availableHeight = geometry.size.height
        let isCompactHeight = availableHeight < 700

        switch position {
        case .top:
            return isCompactHeight ? 8 : 30
        case .bottom:
            return isCompactHeight ? 12 : 40
        }
    }

    /// Returns spacing between elements based on screen height
    private func elementSpacing(for geometry: GeometryProxy) -> CGFloat {
        let availableHeight = geometry.size.height
        return availableHeight < 700 ? 8 : 20
    }

    enum VerticalEdge {
        case top, bottom
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    let currentLandscape = geometry.size.width > geometry.size.height

                    Group {
                        if isLandscape {
                            landscapeLayout(geometry: geometry)
                        } else {
                            portraitLayout(geometry: geometry)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isLandscape)
                    .onAppear {
                        isLandscape = currentLandscape
                    }
                    .onChange(of: currentLandscape) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLandscape = newValue
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CribScore")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(selectedBackground.titleTextColor)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingHistory = true
                        }) {
                            Image(systemName: "clock.fill")
                                .font(.title2)
                                .foregroundColor(selectedBackground.titleTextColor)
                        }
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(selectedBackground.titleTextColor)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Game") {
                        handleNewGameTapped()
                    }
                    .foregroundColor(selectedBackground.titleTextColor)
                }
            }
            .transparentNavigationBar()
        }
        .background(.clear)
        .onAppear {
            if gameViewModel.gameStartTime == nil {
                gameViewModel.startNewGame()
            }
            
            // Ensure NavigationStack background is transparent
            DispatchQueue.main.async {
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows.first {
                    window.rootViewController?.view.backgroundColor = .clear
                }
            }
        }
        .onChange(of: gameViewModel.gameWon) { _, gameWon in
            if gameWon {
                showingWinAlert = true
            }
        }
        .alert(winAlertTitle, isPresented: $showingWinAlert) {
            Button("New Game") {
                showingNewGameSetup = true
            }
            Button("OK") { }
        } message: {
            Text(winAlertMessage)
        }
        .alert("Start New Game?", isPresented: $showingNewGameConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Start New Game") {
                showingNewGameSetup = true
            }
        } message: {
            Text("Are you sure you want to start a new game? The current game will be lost.")
        }
        .sheet(isPresented: $showingNewGameSetup) {
            NewGameSetupView(gameViewModel: gameViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
    }
    
    private func portraitLayout(geometry: GeometryProxy) -> some View {
        let dialSizeValue = dialSize(for: geometry)
        let spacing = elementSpacing(for: geometry)
        let topPadding = verticalPadding(for: geometry, position: .top)
        let bottomPadding = verticalPadding(for: geometry, position: .bottom)
        let isCompact = geometry.size.height < 700
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        // Button should be larger on iPhone - use .body for regular iPhones, .caption only for very compact screens
        let buttonFont: Font = isIPad ? .title3 : (isCompact ? .subheadline : .body)
        // Add more space between dial and button on iPhone
        let dialToButtonSpacing: CGFloat = isIPad ? 20 : (isCompact ? 12 : 20)

        return Group {
            if !gameViewModel.gameWon {
                // Use ScrollView on compact screens to prevent clipping
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Player 2 dial (top, rotated 180° for across-table view)
                        VStack(spacing: spacing) {
                            Text(gameViewModel.player2Name)
                                .font(isCompact ? .subheadline : .headline)
                                .foregroundColor(gameViewModel.player2Color)
                                .padding(.bottom, isCompact ? 16 : 24)

                            ScoreDialView(selectedScore: $gameViewModel.player2SelectedScore)
                                .frame(width: dialSizeValue, height: dialSizeValue)

                            Button(buttonText(for: gameViewModel.player2SelectedScore)) {
                                gameViewModel.applyScoreForPlayer2()
                            }
                            .font(buttonFont)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, isIPad ? 24 : (isCompact ? 16 : 20))
                            .padding(.vertical, isIPad ? 12 : (isCompact ? 8 : 10))
                            .background(buttonColor(for: gameViewModel.player2SelectedScore, playerColor: gameViewModel.player2Color))
                            .cornerRadius(isCompact ? 8 : 10)
                            .disabled(gameViewModel.player2SelectedScore == 0)
                            .padding(.top, dialToButtonSpacing)
                        }
                        .padding(.top, topPadding)
                        .padding(.horizontal, isCompact ? 12 : 20)
                        .rotationEffect(.degrees(180))

                        Spacer(minLength: spacing)

                        // Scores in the middle
                        playerScoresView(isCompact: isCompact)
                            .padding(.vertical, isCompact ? 4 : 8)

                        Spacer(minLength: spacing)

                        // Player 1 dial (bottom, normal orientation)
                        VStack(spacing: spacing) {
                            Text(gameViewModel.player1Name)
                                .font(isCompact ? .subheadline : .headline)
                                .foregroundColor(gameViewModel.player1Color)
                                .padding(.bottom, isCompact ? 16 : 24)

                            ScoreDialView(selectedScore: $gameViewModel.player1SelectedScore)
                                .frame(width: dialSizeValue, height: dialSizeValue)

                            Button(buttonText(for: gameViewModel.player1SelectedScore)) {
                                gameViewModel.applyScoreForPlayer1()
                            }
                            .font(buttonFont)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, isIPad ? 24 : (isCompact ? 16 : 20))
                            .padding(.vertical, isIPad ? 12 : (isCompact ? 8 : 10))
                            .background(buttonColor(for: gameViewModel.player1SelectedScore, playerColor: gameViewModel.player1Color))
                            .cornerRadius(isCompact ? 8 : 10)
                            .disabled(gameViewModel.player1SelectedScore == 0)
                            .padding(.top, dialToButtonSpacing)
                        }
                        .padding(.bottom, bottomPadding)
                        .padding(.horizontal, isCompact ? 12 : 20)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            } else {
                VStack(spacing: 20) {
                    playerScoresView(isCompact: isCompact)
                    Spacer()
                    gameWonView
                    Spacer()
                }
            }
        }
    }
    
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        let dialSizeValue = dialSize(for: geometry)
        let isCompact = geometry.size.height < 400 // Landscape is height-constrained
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let hSpacing: CGFloat = isCompact ? 16 : 40
        let buttonFont: Font = isIPad ? .subheadline : (isCompact ? .caption : .subheadline)
        // iPhone landscape needs tighter spacing
        let vStackSpacing: CGFloat = isIPad ? (isCompact ? 12 : 20) : (isCompact ? 4 : 8)
        let nameToDialPadding: CGFloat = isIPad ? (isCompact ? 12 : 18) : (isCompact ? 4 : 8)
        let dialToButtonPadding: CGFloat = isIPad ? 24 : (isCompact ? 4 : 8)

        return HStack(spacing: hSpacing) {
            if !gameViewModel.gameWon {
                // Player 1 dial (left side)
                VStack(spacing: vStackSpacing) {
                    Text(gameViewModel.player1Name)
                        .font(isCompact ? .caption : .headline)
                        .foregroundColor(gameViewModel.player1Color)
                        .padding(.bottom, nameToDialPadding)

                    ScoreDialView(selectedScore: $gameViewModel.player1SelectedScore)
                        .frame(width: dialSizeValue, height: dialSizeValue)

                    Button(buttonText(for: gameViewModel.player1SelectedScore)) {
                        gameViewModel.applyScoreForPlayer1()
                    }
                    .font(buttonFont)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, isIPad ? 20 : (isCompact ? 10 : 14))
                    .padding(.vertical, isIPad ? 10 : (isCompact ? 4 : 6))
                    .background(buttonColor(for: gameViewModel.player1SelectedScore, playerColor: gameViewModel.player1Color))
                    .cornerRadius(8)
                    .disabled(gameViewModel.player1SelectedScore == 0)
                    .padding(.top, dialToButtonPadding)
                }

                // Scores in the center
                VStack {
                    Spacer()
                    playerScoresView(isCompact: isCompact)
                    Spacer()
                    if gameViewModel.gameWon {
                        gameWonView
                        Spacer()
                    }
                }

                // Player 2 dial (right side)
                VStack(spacing: vStackSpacing) {
                    Text(gameViewModel.player2Name)
                        .font(isCompact ? .caption : .headline)
                        .foregroundColor(gameViewModel.player2Color)
                        .padding(.bottom, nameToDialPadding)

                    ScoreDialView(selectedScore: $gameViewModel.player2SelectedScore)
                        .frame(width: dialSizeValue, height: dialSizeValue)

                    Button(buttonText(for: gameViewModel.player2SelectedScore)) {
                        gameViewModel.applyScoreForPlayer2()
                    }
                    .font(buttonFont)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, isIPad ? 20 : (isCompact ? 10 : 14))
                    .padding(.vertical, isIPad ? 10 : (isCompact ? 4 : 6))
                    .background(buttonColor(for: gameViewModel.player2SelectedScore, playerColor: gameViewModel.player2Color))
                    .cornerRadius(8)
                    .disabled(gameViewModel.player2SelectedScore == 0)
                    .padding(.top, dialToButtonPadding)
                }
            } else {
                VStack {
                    playerScoresView(isCompact: isCompact)
                    Spacer()
                    gameWonView
                    Spacer()
                }
            }
        }
        .padding(.horizontal, isCompact ? 12 : 20)
    }
    
    private func playerScoresView(isCompact: Bool) -> some View {
        let scoreFontSize: CGFloat = isCompact ? 32 : 48
        let nameFont: Font = isCompact ? .subheadline : .title2
        let cardPadding: CGFloat = isCompact ? 8 : 16
        let cornerRadius: CGFloat = isCompact ? 8 : 12

        return HStack(spacing: isCompact ? 8 : 16) {
            VStack(spacing: isCompact ? 2 : 4) {
                Text(gameViewModel.player1Name)
                    .font(nameFont)
                    .fontWeight(.semibold)
                    .foregroundColor(gameViewModel.player1Color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(gameViewModel.player1Score)")
                    .font(.system(size: scoreFontSize, weight: .bold))
                    .foregroundColor(gameViewModel.player1Color)
            }
            .frame(maxWidth: .infinity)
            .padding(cardPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(gameViewModel.player1Color.opacity(0.1))
            )

            VStack(spacing: isCompact ? 2 : 4) {
                Text(gameViewModel.player2Name)
                    .font(nameFont)
                    .fontWeight(.semibold)
                    .foregroundColor(gameViewModel.player2Color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(gameViewModel.player2Score)")
                    .font(.system(size: scoreFontSize, weight: .bold))
                    .foregroundColor(gameViewModel.player2Color)
            }
            .frame(maxWidth: .infinity)
            .padding(cardPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(gameViewModel.player2Color.opacity(0.1))
            )
        }
    }
    
    private var gameWonView: some View {
        let winnerScore = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player1Score : gameViewModel.player2Score
        let loserScore = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player2Score : gameViewModel.player1Score
        let winnerColor = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player1Color : gameViewModel.player2Color
        let loserName = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player2Name : gameViewModel.player1Name

        // Compute skunk status
        let isDoubleSkunk = loserScore < 61
        let isSkunk = loserScore < 91 && loserScore >= 61
        let matchPoints = isDoubleSkunk ? 3 : (isSkunk ? 2 : 1)

        return VStack(spacing: 16) {
            // Victory emoji - different for skunks
            Text(isDoubleSkunk ? "💀💀" : (isSkunk ? "🦨" : "🎉"))
                .font(.system(size: 60))

            Text("\(gameViewModel.winner) Wins!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(winnerColor)

            Text("Final Score: \(winnerScore) - \(loserScore)")
                .font(.title2)
                .foregroundColor(.secondary)

            // Skunk indicator
            if isDoubleSkunk {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.red)
                    Text("Double Skunk!")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.red)
                }
                .font(.title3)

                Text("\(loserName) didn't reach 61 points")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if isSkunk {
                HStack(spacing: 8) {
                    Image(systemName: "bolt")
                        .foregroundColor(.orange)
                    Text("Skunk!")
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Image(systemName: "bolt")
                        .foregroundColor(.orange)
                }
                .font(.title3)

                Text("\(loserName) didn't reach 91 points")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Match points earned
            HStack(spacing: 4) {
                Text("\(matchPoints)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(winnerColor)
                Text(matchPoints == 1 ? "match point" : "match points")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)

            Button("Start New Game") {
                showingNewGameSetup = true
            }
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(winnerColor)
            .cornerRadius(12)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Win Alert Helpers

    private var winAlertTitle: String {
        let loserScore = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player2Score : gameViewModel.player1Score
        if loserScore < 61 {
            return "Double Skunk!"
        } else if loserScore < 91 {
            return "Skunk!"
        }
        return "Game Over!"
    }

    private var winAlertMessage: String {
        let winnerScore = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player1Score : gameViewModel.player2Score
        let loserScore = gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player2Score : gameViewModel.player1Score
        let isDoubleSkunk = loserScore < 61
        let isSkunk = loserScore < 91 && loserScore >= 61
        let matchPoints = isDoubleSkunk ? 3 : (isSkunk ? 2 : 1)

        var message = "\(gameViewModel.winner) wins \(winnerScore) to \(loserScore)!"

        if isDoubleSkunk {
            message += "\n\nDouble skunk - \(matchPoints) match points!"
        } else if isSkunk {
            message += "\n\nSkunk - \(matchPoints) match points!"
        } else {
            message += "\n\n\(matchPoints) match point earned."
        }

        return message
    }

    // MARK: - Helper Functions

    private func handleNewGameTapped() {
        if gameViewModel.isGameInProgress {
            showingNewGameConfirmation = true
        } else {
            showingNewGameSetup = true
        }
    }
    
    private func buttonText(for score: Int) -> String {
        switch score {
        case ..<0:
            return "Subtract \(abs(score))"
        case 0:
            return "Select Points"
        default:
            return "Add \(score)"
        }
    }
    
    private func buttonColor(for score: Int, playerColor: Color) -> Color {
        switch score {
        case ..<0:
            return .red
        case 0:
            return .gray
        default:
            return playerColor
        }
    }
}

#Preview {
    MainGameView()
        .environmentObject(GameViewModel())
}