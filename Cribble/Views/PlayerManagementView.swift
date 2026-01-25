//
//  PlayerManagementView.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import SwiftUI
import CoreData

struct PlayerManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.name, ascending: true)],
        animation: .default
    )
    private var players: FetchedResults<Player>

    @State private var selectedPlayer: Player?
    @State private var showingRenameSheet = false
    @State private var showingMergeSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                if players.isEmpty {
                    emptyStateView
                } else {
                    ForEach(players) { player in
                        PlayerManagementRow(
                            player: player,
                            onRename: {
                                selectedPlayer = player
                                showingRenameSheet = true
                            },
                            onMerge: {
                                selectedPlayer = player
                                showingMergeSheet = true
                            },
                            onDelete: {
                                selectedPlayer = player
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("Manage Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingRenameSheet) {
                if let player = selectedPlayer {
                    RenamePlayerSheet(player: player)
                }
            }
            .sheet(isPresented: $showingMergeSheet) {
                if let player = selectedPlayer {
                    MergePlayerSheet(sourcePlayer: player, allPlayers: Array(players))
                }
            }
            .alert("Delete Player", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let player = selectedPlayer {
                        deletePlayer(player)
                    }
                }
            } message: {
                if let player = selectedPlayer {
                    Text("Are you sure you want to delete \(player.name ?? "this player")? Their game history will remain but won't be linked to any player.")
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Players Yet")
                .font(.headline)

            Text("Players are created when you start a new game.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func deletePlayer(_ player: Player) {
        // Unlink games but don't delete them
        if let wonGames = player.gamesWon as? Set<Game> {
            for game in wonGames {
                game.winnerPlayer = nil
            }
        }
        if let lostGames = player.gamesLost as? Set<Game> {
            for game in lostGames {
                game.loserPlayer = nil
            }
        }

        viewContext.delete(player)
        try? viewContext.save()
    }
}

// MARK: - Player Row

struct PlayerManagementRow: View {
    let player: Player
    let onRename: () -> Void
    let onMerge: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name ?? "Unknown")
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Text("\(player.totalGamesPlayed) games")
                    Text("\(player.totalWins)W - \(player.totalLosses)L")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Menu {
                Button {
                    onRename()
                } label: {
                    Label("Rename", systemImage: "pencil")
                }

                Button {
                    onMerge()
                } label: {
                    Label("Merge Into...", systemImage: "arrow.triangle.merge")
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Rename Sheet

struct RenamePlayerSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let player: Player
    @State private var newName: String

    init(player: Player) {
        self.player = player
        self._newName = State(initialValue: player.name ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Player Name")) {
                    TextField("Name", text: $newName)
                }

                Section {
                    Text("This will update the player's name across all games and statistics.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Rename Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRename()
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveRename() {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        player.name = trimmed
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - Merge Sheet

struct MergePlayerSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let sourcePlayer: Player
    let allPlayers: [Player]

    @State private var targetPlayer: Player?
    @State private var showingConfirmation = false

    var availableTargets: [Player] {
        allPlayers.filter { $0.id != sourcePlayer.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Merging")) {
                    HStack {
                        Text(sourcePlayer.name ?? "Unknown")
                            .fontWeight(.medium)
                        Text("(\(sourcePlayer.totalGamesPlayed) games)")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Into")) {
                    if availableTargets.isEmpty {
                        Text("No other players available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(availableTargets) { player in
                            Button {
                                targetPlayer = player
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(player.name ?? "Unknown")
                                            .foregroundColor(.primary)
                                        Text("\(player.totalGamesPlayed) games")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if targetPlayer?.id == player.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    Text("All games from \"\(sourcePlayer.name ?? "this player")\" will be moved to the selected player. The original player will be deleted.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Merge Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Merge") {
                        showingConfirmation = true
                    }
                    .disabled(targetPlayer == nil)
                    .fontWeight(.semibold)
                }
            }
            .alert("Confirm Merge", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Merge", role: .destructive) {
                    performMerge()
                }
            } message: {
                if let target = targetPlayer {
                    Text("Merge \"\(sourcePlayer.name ?? "Unknown")\" into \"\(target.name ?? "Unknown")\"? This cannot be undone.")
                }
            }
        }
    }

    private func performMerge() {
        guard let target = targetPlayer else { return }
        target.merge(from: sourcePlayer, in: viewContext)
        dismiss()
    }
}

#Preview {
    PlayerManagementView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
