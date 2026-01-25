//
//  PlayerPickerView.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import SwiftUI
import CoreData

struct PlayerPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var selectedPlayer: Player?
    @Binding var playerName: String
    let placeholder: String

    @State private var suggestions: [Player] = []
    @State private var showSuggestions = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(placeholder, text: $playerName)
                .focused($isTextFieldFocused)
                .onChange(of: playerName) { _, newValue in
                    updateSuggestions(for: newValue)
                }
                .onChange(of: isTextFieldFocused) { _, focused in
                    if focused && !playerName.isEmpty {
                        updateSuggestions(for: playerName)
                    } else if !focused {
                        // Delay hiding to allow button taps to register
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showSuggestions = false
                        }
                    }
                }

            if showSuggestions {
                suggestionsList
            }
        }
    }

    private var suggestionsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Existing player suggestions
            ForEach(suggestions) { player in
                Button {
                    selectPlayer(player)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name ?? "Unknown")
                                .foregroundColor(.primary)

                            if hasDuplicateName(player) {
                                Text(formatCreatedDate(player.createdAt))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Text("\(player.totalGamesPlayed) games")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if player != suggestions.last {
                    Divider()
                        .padding(.leading, 12)
                }
            }

            // Create new player option
            if !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !suggestions.contains(where: { $0.name?.lowercased() == playerName.lowercased() }) {
                Divider()
                    .padding(.leading, 12)

                Button {
                    createNewPlayer()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Create \"\(playerName.trimmingCharacters(in: .whitespacesAndNewlines))\"")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.top, 4)
    }

    private func updateSuggestions(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            // Show recent players when field is empty but focused
            suggestions = Array(Player.fetchAllPlayers(in: viewContext).prefix(5))
        } else {
            suggestions = Player.searchPlayers(matching: trimmed, in: viewContext)
        }
        showSuggestions = isTextFieldFocused && (!suggestions.isEmpty || !trimmed.isEmpty)
    }

    private func selectPlayer(_ player: Player) {
        selectedPlayer = player
        playerName = player.name ?? ""
        showSuggestions = false
        isTextFieldFocused = false
    }

    private func createNewPlayer() {
        selectedPlayer = nil // Will be created on game save
        showSuggestions = false
        isTextFieldFocused = false
    }

    private func hasDuplicateName(_ player: Player) -> Bool {
        guard let name = player.name else { return false }
        return suggestions.filter { $0.name?.lowercased() == name.lowercased() }.count > 1
    }

    private func formatCreatedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "added \(formatter.string(from: date))"
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var player: Player?
        @State private var name = ""

        var body: some View {
            Form {
                Section("Player") {
                    PlayerPickerView(
                        selectedPlayer: $player,
                        playerName: $name,
                        placeholder: "Player Name"
                    )
                }
            }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }

    return PreviewWrapper()
}
