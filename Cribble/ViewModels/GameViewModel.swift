import SwiftUI
import CoreData

class GameViewModel: ObservableObject {
    @Published var player1Name: String = "Player 1"
    @Published var player2Name: String = "Player 2"
    @Published var player1Color: Color = .blue
    @Published var player2Color: Color = .orange
    @Published var player1Score: Int = 0
    @Published var player2Score: Int = 0
    @Published var player1SelectedScore: Int = 0
    @Published var player2SelectedScore: Int = 0
    @Published var gameStartTime: Date?
    @Published var gameWon: Bool = false
    @Published var winner: String = ""
    
    private let persistenceController = PersistenceController.shared
    private let winningScore = 121
    
    var isGameInProgress: Bool {
        return !gameWon && (player1Score > 0 || player2Score > 0) && gameStartTime != nil
    }
    
    func startNewGame() {
        player1Score = 0
        player2Score = 0
        player1SelectedScore = 0
        player2SelectedScore = 0
        gameStartTime = Date()
        gameWon = false
        winner = ""
    }
    
    func startNewGame(player1Name: String, player2Name: String, player1Color: Color, player2Color: Color) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.player1Color = player1Color
        self.player2Color = player2Color
        startNewGame()
    }
    
    func applyScoreForPlayer1() {
        if gameWon { return }
        
        // Apply the score change (positive or negative)
        player1Score = max(0, player1Score + player1SelectedScore)
        
        // Check for win condition
        if player1Score >= winningScore {
            endGame(winner: player1Name, loser: player2Name, winnerScore: player1Score, loserScore: player2Score)
        }
        
        // Reset dial to neutral
        player1SelectedScore = 0
    }
    
    func applyScoreForPlayer2() {
        if gameWon { return }
        
        // Apply the score change (positive or negative)
        player2Score = max(0, player2Score + player2SelectedScore)
        
        // Check for win condition
        if player2Score >= winningScore {
            endGame(winner: player2Name, loser: player1Name, winnerScore: player2Score, loserScore: player1Score)
        }
        
        // Reset dial to neutral
        player2SelectedScore = 0
    }
    
    private func endGame(winner: String, loser: String, winnerScore: Int, loserScore: Int) {
        gameWon = true
        self.winner = winner
        
        let duration = gameStartTime?.timeIntervalSinceNow.magnitude ?? 0
        
        persistenceController.saveGame(
            winner: winner,
            loser: loser,
            winnerScore: Int16(winnerScore),
            loserScore: Int16(loserScore),
            duration: duration
        )
    }
    
}