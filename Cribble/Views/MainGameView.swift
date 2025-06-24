import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var showingWinAlert = false
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
                        gameViewModel.startNewGame()
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
                gameViewModel.startNewGame()
            }
            Button("OK") { }
        } message: {
            Text("\(gameViewModel.winner) wins with \(gameViewModel.winner == gameViewModel.player1Name ? gameViewModel.player1Score : gameViewModel.player2Score) points!")
        }
    }
    
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            if !gameViewModel.gameWon {
                // Player 2 dial (top, rotated 180° for across-table view)
                VStack(spacing: 20) {
                    Text(gameViewModel.player2Name)
                        .font(.headline)
                        .foregroundColor(.orange)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player2SelectedScore)
                        .frame(width: 160, height: 160)
                    
                    Button("Add \(gameViewModel.player2SelectedScore)") {
                        gameViewModel.addScoreForPlayer2()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                .padding(.top, 30)
                .rotationEffect(.degrees(180))
                
                Spacer()
                
                // Scores in the middle
                playerScoresView
                    .padding(.vertical, 20)
                
                Spacer()
                
                // Player 1 dial (bottom, normal orientation)
                VStack(spacing: 20) {
                    Text(gameViewModel.player1Name)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player1SelectedScore)
                        .frame(width: 160, height: 160)
                    
                    Button("Add \(gameViewModel.player1SelectedScore)") {
                        gameViewModel.addScoreForPlayer1()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.bottom, 30)
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
                        .foregroundColor(.blue)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player1SelectedScore)
                        .frame(width: 140, height: 140)
                    
                    Button("Add \(gameViewModel.player1SelectedScore)") {
                        gameViewModel.addScoreForPlayer1()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
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
                        .foregroundColor(.orange)
                        .padding(.bottom, 5)
                    
                    ScoreDialView(selectedScore: $gameViewModel.player2SelectedScore)
                        .frame(width: 140, height: 140)
                    
                    Button("Add \(gameViewModel.player2SelectedScore)") {
                        gameViewModel.addScoreForPlayer2()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
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
                    .foregroundColor(.blue)
                
                Text("\(gameViewModel.player1Score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            
            VStack {
                Text(gameViewModel.player2Name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text("\(gameViewModel.player2Score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
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
                gameViewModel.startNewGame()
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
}

#Preview {
    MainGameView()
        .environmentObject(GameViewModel())
}