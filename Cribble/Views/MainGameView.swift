import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var showingWinAlert = false
    @State private var showingNewGameConfirmation = false
    @State private var showingNewGameSetup = false
    @State private var isLandscape = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let currentLandscape = geometry.size.width > geometry.size.height
                
                Group {
                    if isLandscape {
                        landscapeLayout
                    } else {
                        portraitLayout
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isLandscape)
                .onAppear {
                    isLandscape = currentLandscape
                }
                .onChange(of: currentLandscape) { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLandscape = newValue
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cribble")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Game") {
                        handleNewGameTapped()
                    }
                }
            }
        }
        .onAppear {
            if gameViewModel.gameStartTime == nil {
                gameViewModel.startNewGame()
            }
        }
        .onChange(of: gameViewModel.gameWon) { gameWon in
            if gameWon {
                showingWinAlert = true
            }
        }
        .alert("Game Over!", isPresented: $showingWinAlert) {
            Button("New Game") {
                showingNewGameSetup = true
            }
            Button("OK") { }
        } message: {
            Text("\(gameViewModel.winner) wins with \(gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player1Score : gameViewModel.player2Score) points!")
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
    }
    
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            if !gameViewModel.gameWon {
                // Player 2 dial (top, rotated 180° for across-table view)
                VStack(spacing: 20) {
                    Text(gameViewModel.player2Name)
                        .font(.headline)
                        .foregroundColor(gameViewModel.player2Color)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player2SelectedScore)
                        .frame(width: 160, height: 160)
                    
                    Button(buttonText(for: gameViewModel.player2SelectedScore)) {
                        gameViewModel.applyScoreForPlayer2()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(buttonColor(for: gameViewModel.player2SelectedScore, playerColor: gameViewModel.player2Color))
                    .cornerRadius(10)
                    .disabled(gameViewModel.player2SelectedScore == 0)
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                .rotationEffect(.degrees(180))
                
                Spacer()
                
                // Scores in the middle
                playerScoresView
                    .padding(.vertical, 8)
                
                Spacer()
                
                // Player 1 dial (bottom, normal orientation)
                VStack(spacing: 20) {
                    Text(gameViewModel.player1Name)
                        .font(.headline)
                        .foregroundColor(gameViewModel.player1Color)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player1SelectedScore)
                        .frame(width: 160, height: 160)
                    
                    Button(buttonText(for: gameViewModel.player1SelectedScore)) {
                        gameViewModel.applyScoreForPlayer1()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(buttonColor(for: gameViewModel.player1SelectedScore, playerColor: gameViewModel.player1Color))
                    .cornerRadius(10)
                    .disabled(gameViewModel.player1SelectedScore == 0)
                }
                .padding(.bottom, 40)
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 20) {
                    playerScoresView
                    Spacer()
                    gameWonView
                    Spacer()
                }
            }
        }
    }
    
    private var landscapeLayout: some View {
        HStack(spacing: 40) {
            if !gameViewModel.gameWon {
                // Player 1 dial (left side)
                VStack(spacing: 20) {
                    Text(gameViewModel.player1Name)
                        .font(.headline)
                        .foregroundColor(gameViewModel.player1Color)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player1SelectedScore)
                        .frame(width: 140, height: 140)
                    
                    Button(buttonText(for: gameViewModel.player1SelectedScore)) {
                        gameViewModel.applyScoreForPlayer1()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(buttonColor(for: gameViewModel.player1SelectedScore, playerColor: gameViewModel.player1Color))
                    .cornerRadius(8)
                    .disabled(gameViewModel.player1SelectedScore == 0)
                }
                
                // Scores in the center
                VStack {
                    Spacer()
                    playerScoresView
                    Spacer()
                    if gameViewModel.gameWon {
                        gameWonView
                        Spacer()
                    }
                }
                
                // Player 2 dial (right side)
                VStack(spacing: 20) {
                    Text(gameViewModel.player2Name)
                        .font(.headline)
                        .foregroundColor(gameViewModel.player2Color)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player2SelectedScore)
                        .frame(width: 140, height: 140)
                    
                    Button(buttonText(for: gameViewModel.player2SelectedScore)) {
                        gameViewModel.applyScoreForPlayer2()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(buttonColor(for: gameViewModel.player2SelectedScore, playerColor: gameViewModel.player2Color))
                    .cornerRadius(8)
                    .disabled(gameViewModel.player2SelectedScore == 0)
                }
            } else {
                VStack {
                    playerScoresView
                    Spacer()
                    gameWonView
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var playerScoresView: some View {
        HStack {
            VStack {
                Text(gameViewModel.player1Name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(gameViewModel.player1Color)
                
                Text("\(gameViewModel.player1Score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(gameViewModel.player1Color)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(gameViewModel.player1Color.opacity(0.1))
            )
            
            VStack {
                Text(gameViewModel.player2Name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(gameViewModel.player2Color)
                
                Text("\(gameViewModel.player2Score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(gameViewModel.player2Color)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(gameViewModel.player2Color.opacity(0.1))
            )
        }
    }
    
    private var gameWonView: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("\(gameViewModel.winner) Wins!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Final Score: \(gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player1Score : gameViewModel.player2Score) - \(gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player2Score : gameViewModel.player1Score)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button("Start New Game") {
                showingNewGameSetup = true
            }
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
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