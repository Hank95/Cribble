import SwiftUI
import CoreData

class GameViewModel: ObservableObject {
    @Published var player1Name: String = "Player 1"
    @Published var player2Name: String = "Player 2"
    @Published var player1Score: Int = 0
    @Published var player2Score: Int = 0
    @Published var player1SelectedScore: Int = 1
    @Published var player2SelectedScore: Int = 1
    @Published var gameStartTime: Date?
    @Published var gameWon: Bool = false
    @Published var winner: String = ""
    
    private let persistenceController = PersistenceController.shared
    private let winningScore = 121
    
    func startNewGame() {
        player1Score = 0
        player2Score = 0
        player1SelectedScore = 1
        player2SelectedScore = 1
        gameStartTime = Date()
        gameWon = false
        winner = ""
    }
    
    func addScoreForPlayer1() {
        if gameWon { return }
        
        player1Score += player1SelectedScore
        if player1Score >= winningScore {
            endGame(winner: player1Name, loser: player2Name, winnerScore: player1Score, loserScore: player2Score)
        }
        player1SelectedScore = 1
    }
    
    func addScoreForPlayer2() {
        if gameWon { return }
        
        player2Score += player2SelectedScore
        if player2Score >= winningScore {
            endGame(winner: player2Name, loser: player1Name, winnerScore: player2Score, loserScore: player1Score)
        }
        player2SelectedScore = 1
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