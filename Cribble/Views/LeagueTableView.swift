//
//  LeagueTableView.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import SwiftUI

struct LeagueTableView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LeagueViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.standings.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    leagueList
                }
            }
            .navigationTitle("League Table")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadStats(context: viewContext)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Games Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Play some games to see the league standings!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var leagueList: some View {
        List {
            // Header row
            Section {
                HStack(spacing: 8) {
                    Text("#")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 24, alignment: .center)

                    Text("Player")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Text("W-L")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 50, alignment: .center)

                    Text("Pts")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 40, alignment: .trailing)
                }
                .foregroundColor(.secondary)
            }

            // Player rows
            Section {
                ForEach(Array(viewModel.standings.enumerated()), id: \.element.id) { index, stats in
                    LeagueRowView(rank: index + 1, stats: stats)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct LeagueRowView: View {
    let rank: Int
    let stats: StatsService.PlayerLeagueStats

    var body: some View {
        HStack(spacing: 8) {
            // Rank with medal for top 3
            rankBadge
                .frame(width: 24, alignment: .center)

            // Player name and win percentage
            VStack(alignment: .leading, spacing: 2) {
                Text(stats.player.name ?? "Unknown")
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Text(String(format: "%.0f%%", stats.winPercentage))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if stats.skunks > 0 || stats.doubleSkunks > 0 {
                        skunkIndicators
                    }
                }
            }

            Spacer()

            // Win-Loss record
            Text("\(stats.wins)-\(stats.losses)")
                .font(.body)
                .monospacedDigit()
                .frame(width: 50, alignment: .center)

            // Match points
            Text("\(stats.matchPoints)")
                .font(.body)
                .fontWeight(.semibold)
                .monospacedDigit()
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var rankBadge: some View {
        switch rank {
        case 1:
            Image(systemName: "medal.fill")
                .foregroundColor(.yellow)
        case 2:
            Image(systemName: "medal.fill")
                .foregroundColor(.gray)
        case 3:
            Image(systemName: "medal.fill")
                .foregroundColor(.brown)
        default:
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var skunkIndicators: some View {
        HStack(spacing: 2) {
            if stats.doubleSkunks > 0 {
                HStack(spacing: 1) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 8))
                    Text("\(stats.doubleSkunks)")
                        .font(.system(size: 9))
                }
                .foregroundColor(.red)
            }

            if stats.skunks > 0 {
                HStack(spacing: 1) {
                    Image(systemName: "bolt")
                        .font(.system(size: 8))
                    Text("\(stats.skunks)")
                        .font(.system(size: 9))
                }
                .foregroundColor(.orange)
            }
        }
    }
}

#Preview {
    LeagueTableView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
