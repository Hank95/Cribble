import SwiftUI

struct NewGameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    
    @State private var player1Name: String
    @State private var player2Name: String
    @State private var player1Color: Color
    @State private var player2Color: Color
    
    let availableColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .cyan, .mint, .teal, .indigo]
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        self._player1Name = State(initialValue: gameViewModel.player1Name)
        self._player2Name = State(initialValue: gameViewModel.player2Name)
        self._player1Color = State(initialValue: gameViewModel.player1Color)
        self._player2Color = State(initialValue: gameViewModel.player2Color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Player 1") {
                    TextField("Player 1 Name", text: $player1Name)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                ColorSelectionButton(
                                    color: color,
                                    isSelected: color == player1Color,
                                    action: { player1Color = color }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Player 2") {
                    TextField("Player 2 Name", text: $player2Name)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                ColorSelectionButton(
                                    color: color,
                                    isSelected: color == player2Color,
                                    action: { player2Color = color }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Game Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start Game") {
                        gameViewModel.startNewGame(
                            player1Name: player1Name.isEmpty ? "Player 1" : player1Name,
                            player2Name: player2Name.isEmpty ? "Player 2" : player2Name,
                            player1Color: player1Color,
                            player2Color: player2Color
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ColorSelectionButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NewGameSetupView(gameViewModel: GameViewModel())
}