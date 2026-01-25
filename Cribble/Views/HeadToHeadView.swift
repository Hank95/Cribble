//
//  HeadToHeadView.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import SwiftUI

struct HeadToHeadView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HeadToHeadViewModel()

    @State private var player1: Player?
    @State private var player2: Player?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Player selection section
                playerSelectionSection
                    .padding()

                Divider()

                // Stats display
                if let stats = viewModel.stats {
                    ScrollView {
                        VStack(spacing: 24) {
                            winComparisonCard(stats: stats)
                            matchPointsCard(stats: stats)
                            skunksCard(stats: stats)
                            recentGamesSection(stats: stats)
                        }
                        .padding()
                    }
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Head to Head")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadPlayers(context: viewContext)
            }
            .onChange(of: player1) { _, _ in loadStats() }
            .onChange(of: player2) { _, _ in loadStats() }
        }
    }

    // MARK: - Player Selection

    private var playerSelectionSection: some View {
        HStack(spacing: 16) {
            PlayerDropdown(
                selection: $player1,
                players: viewModel.allPlayers.filter { $0.id != player2?.id },
                label: "Player 1"
            )

            Text("vs")
                .font(.headline)
                .foregroundColor(.secondary)

            PlayerDropdown(
                selection: $player2,
                players: viewModel.allPlayers.filter { $0.id != player1?.id },
                label: "Player 2"
            )
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Select Two Players")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose two different players to compare their head-to-head record.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Stats Cards

    private func winComparisonCard(stats: StatsService.HeadToHeadStats) -> some View {
        VStack(spacing: 12) {
            Text("WINS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                // Player 1 side
                VStack(spacing: 4) {
                    Text("\(stats.player1Wins)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(stats.player1Wins > stats.player2Wins ? .green : .primary)

                    Text(stats.player1.name ?? "Player 1")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text(String(format: "%.0f%%", stats.player1WinPercentage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Center divider
                VStack {
                    Text("-")
                        .font(.title)
                        .foregroundColor(.secondary)
                }

                // Player 2 side
                VStack(spacing: 4) {
                    Text("\(stats.player2Wins)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(stats.player2Wins > stats.player1Wins ? .green : .primary)

                    Text(stats.player2.name ?? "Player 2")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text(String(format: "%.0f%%", stats.player2WinPercentage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            Text("\(stats.totalGames) games played")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func matchPointsCard(stats: StatsService.HeadToHeadStats) -> some View {
        VStack(spacing: 8) {
            Text("MATCH POINTS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack {
                Text("\(stats.player1MatchPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)

                Text("-")
                    .foregroundColor(.secondary)

                Text("\(stats.player2MatchPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func skunksCard(stats: StatsService.HeadToHeadStats) -> some View {
        VStack(spacing: 8) {
            Text("SKUNKS DEALT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        if stats.player1DoubleSkunks > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "bolt.fill")
                                    .font(.caption)
                                Text("\(stats.player1DoubleSkunks)")
                            }
                            .foregroundColor(.red)
                        }
                        if stats.player1Skunks > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "bolt")
                                    .font(.caption)
                                Text("\(stats.player1Skunks)")
                            }
                            .foregroundColor(.orange)
                        }
                        if stats.player1Skunks == 0 && stats.player1DoubleSkunks == 0 {
                            Text("0")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)

                Text("-")
                    .foregroundColor(.secondary)

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        if stats.player2DoubleSkunks > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "bolt.fill")
                                    .font(.caption)
                                Text("\(stats.player2DoubleSkunks)")
                            }
                            .foregroundColor(.red)
                        }
                        if stats.player2Skunks > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "bolt")
                                    .font(.caption)
                                Text("\(stats.player2Skunks)")
                            }
                            .foregroundColor(.orange)
                        }
                        if stats.player2Skunks == 0 && stats.player2DoubleSkunks == 0 {
                            Text("0")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt")
                        .font(.caption2)
                    Text("Skunk")
                }
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                    Text("Double Skunk")
                }
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func recentGamesSection(stats: StatsService.HeadToHeadStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT GAMES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            if stats.recentGames.isEmpty {
                Text("No games yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(stats.recentGames, id: \.id) { game in
                    recentGameRow(game: game, stats: stats)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func recentGameRow(game: Game, stats: StatsService.HeadToHeadStats) -> some View {
        let player1Won = game.winnerPlayer?.id == stats.player1.id

        return HStack {
            // Player 1 score
            Text("\(player1Won ? game.winnerScore : game.loserScore)")
                .font(.body)
                .fontWeight(player1Won ? .bold : .regular)
                .foregroundColor(player1Won ? .green : .primary)
                .frame(width: 40, alignment: .trailing)

            Spacer()

            // Game info
            VStack(spacing: 2) {
                Text(formatDate(game.date))
                    .font(.caption)
                    .foregroundColor(.secondary)

                if game.isDoubleSkunk {
                    Text("Double Skunk!")
                        .font(.caption2)
                        .foregroundColor(.red)
                } else if game.isSkunk {
                    Text("Skunk")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            // Player 2 score
            Text("\(!player1Won ? game.winnerScore : game.loserScore)")
                .font(.body)
                .fontWeight(!player1Won ? .bold : .regular)
                .foregroundColor(!player1Won ? .green : .primary)
                .frame(width: 40, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func loadStats() {
        viewModel.loadStats(player1: player1, player2: player2, context: viewContext)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Player Dropdown Component

struct PlayerDropdown: View {
    @Binding var selection: Player?
    let players: [Player]
    let label: String

    var body: some View {
        Menu {
            Button("Select \(label)") {
                selection = nil
            }

            Divider()

            ForEach(players) { player in
                Button {
                    selection = player
                } label: {
                    HStack {
                        Text(player.name ?? "Unknown")
                        if selection?.id == player.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selection?.name ?? label)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HeadToHeadView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
