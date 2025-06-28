import SwiftUI

struct ScoringOverlayView: View {
    @ObservedObject var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            // Progress ring overlay that covers the entire screen
            CircularScoreProgressView(
                player1Score: gameViewModel.player1Score,
                player2Score: gameViewModel.player2Score,
                player1Name: gameViewModel.player1Name,
                player2Name: gameViewModel.player2Name,
                player1Color: gameViewModel.player1Color,
                player2Color: gameViewModel.player2Color,
                gameWon: gameViewModel.gameWon,
                winner: gameViewModel.winner,
                onAnimationComplete: {
                    gameViewModel.startNewGame()
                }
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
            .allowsHitTesting(gameViewModel.gameWon) // Allow touches only when game is won
        }
        .allowsHitTesting(gameViewModel.gameWon) // Allow touches only when game is won
    }
}

#Preview {
    ScoringOverlayView(gameViewModel: GameViewModel())
        .frame(width: 350, height: 600)
        .background(Color.gray.opacity(0.1))
}