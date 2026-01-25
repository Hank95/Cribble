import SwiftUI

struct NewGameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var gameViewModel: GameViewModel

    @State private var player1Name: String
    @State private var player2Name: String
    @State private var player1Color: Color
    @State private var player2Color: Color
    @State private var selectedPlayer1: Player?
    @State private var selectedPlayer2: Player?

    let availableColors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .cyan, .mint, .teal, .indigo]

    // Adaptive grid that adjusts based on available width
    private let adaptiveColumns = [GridItem(.adaptive(minimum: 44, maximum: 60))]

    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        self._player1Name = State(initialValue: gameViewModel.player1Name)
        self._player2Name = State(initialValue: gameViewModel.player2Name)
        self._player1Color = State(initialValue: gameViewModel.player1Color)
        self._player2Color = State(initialValue: gameViewModel.player2Color)
        self._selectedPlayer1 = State(initialValue: nil)
        self._selectedPlayer2 = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Player 1") {
                    PlayerPickerView(
                        selectedPlayer: $selectedPlayer1,
                        playerName: $player1Name,
                        placeholder: "Player 1 Name"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: adaptiveColumns, spacing: 10) {
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
                    PlayerPickerView(
                        selectedPlayer: $selectedPlayer2,
                        playerName: $player2Name,
                        placeholder: "Player 2 Name"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: adaptiveColumns, spacing: 10) {
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
                        // Get or create players
                        let p1 = selectedPlayer1 ?? Player.fetchOrCreate(
                            name: player1Name.isEmpty ? "Player 1" : player1Name,
                            in: viewContext
                        )
                        let p2 = selectedPlayer2 ?? Player.fetchOrCreate(
                            name: player2Name.isEmpty ? "Player 2" : player2Name,
                            in: viewContext
                        )

                        // Update preferred colors if changed
                        p1.preferredColor = colorToString(player1Color)
                        p2.preferredColor = colorToString(player2Color)
                        try? viewContext.save()

                        gameViewModel.startNewGame(
                            player1: p1,
                            player2: p2,
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

    private func colorToString(_ color: Color) -> String {
        switch color {
        case .blue: return "blue"
        case .red: return "red"
        case .green: return "green"
        case .orange: return "orange"
        case .purple: return "purple"
        case .pink: return "pink"
        case .cyan: return "cyan"
        case .mint: return "mint"
        case .teal: return "teal"
        case .indigo: return "indigo"
        default: return "blue"
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
                .aspectRatio(1, contentMode: .fit)
                .frame(minWidth: 36, maxWidth: 44)
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