//
//  StatsService.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import Foundation
import CoreData

class StatsService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - League Stats

    struct PlayerLeagueStats: Identifiable {
        let id: UUID
        let player: Player
        var gamesPlayed: Int = 0
        var wins: Int = 0
        var losses: Int = 0
        var skunks: Int = 0           // Skunks dealt (won with loser < 91)
        var doubleSkunks: Int = 0     // Double skunks dealt (won with loser < 61)
        var skunkedBy: Int = 0        // Times skunked by opponent
        var doubleSkunkedBy: Int = 0  // Times double skunked
        var matchPoints: Int = 0
        var totalMargin: Int = 0       // Sum of (winnerScore - loserScore) for wins, negative for losses

        var winPercentage: Double {
            gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) * 100 : 0
        }

        var averageMargin: Double {
            gamesPlayed > 0 ? Double(totalMargin) / Double(gamesPlayed) : 0
        }
    }

    /// Fetches league standings sorted by match points (descending)
    func fetchLeagueTable() -> [PlayerLeagueStats] {
        let players = Player.fetchAllPlayers(in: context)
        return players.map { computeStats(for: $0) }
            .filter { $0.gamesPlayed > 0 }
            .sorted { ($0.matchPoints, $0.wins, $0.winPercentage) > ($1.matchPoints, $1.wins, $1.winPercentage) }
    }

    private func computeStats(for player: Player) -> PlayerLeagueStats {
        guard let playerId = player.id else {
            return PlayerLeagueStats(id: UUID(), player: player)
        }

        var stats = PlayerLeagueStats(id: playerId, player: player)

        let gamesWon = (player.gamesWon as? Set<Game>) ?? []
        let gamesLost = (player.gamesLost as? Set<Game>) ?? []

        stats.wins = gamesWon.count
        stats.losses = gamesLost.count
        stats.gamesPlayed = stats.wins + stats.losses

        // Process won games
        for game in gamesWon {
            stats.totalMargin += game.margin
            stats.matchPoints += game.matchPoints

            if game.isDoubleSkunk {
                stats.doubleSkunks += 1
            } else if game.isSkunk {
                stats.skunks += 1
            }
        }

        // Process lost games
        for game in gamesLost {
            stats.totalMargin -= game.margin

            if game.isDoubleSkunk {
                stats.doubleSkunkedBy += 1
            } else if game.isSkunk {
                stats.skunkedBy += 1
            }
        }

        return stats
    }

    // MARK: - Head-to-Head Stats

    struct HeadToHeadStats {
        let player1: Player
        let player2: Player
        var player1Wins: Int = 0
        var player2Wins: Int = 0
        var player1Skunks: Int = 0
        var player2Skunks: Int = 0
        var player1DoubleSkunks: Int = 0
        var player2DoubleSkunks: Int = 0
        var player1MatchPoints: Int = 0
        var player2MatchPoints: Int = 0
        var totalGames: Int = 0
        var recentGames: [Game] = []

        var player1WinPercentage: Double {
            totalGames > 0 ? Double(player1Wins) / Double(totalGames) * 100 : 0
        }

        var player2WinPercentage: Double {
            totalGames > 0 ? Double(player2Wins) / Double(totalGames) * 100 : 0
        }
    }

    /// Computes head-to-head statistics between two players
    func headToHead(player1: Player, player2: Player) -> HeadToHeadStats {
        var stats = HeadToHeadStats(player1: player1, player2: player2)

        let games = Game.gamesBetween(player1: player1, player2: player2, in: context)
        stats.totalGames = games.count
        stats.recentGames = Array(games.prefix(5))

        for game in games {
            let p1Won = game.winnerPlayer?.id == player1.id

            if p1Won {
                stats.player1Wins += 1
                stats.player1MatchPoints += game.matchPoints

                if game.isDoubleSkunk {
                    stats.player1DoubleSkunks += 1
                } else if game.isSkunk {
                    stats.player1Skunks += 1
                }
            } else {
                stats.player2Wins += 1
                stats.player2MatchPoints += game.matchPoints

                if game.isDoubleSkunk {
                    stats.player2DoubleSkunks += 1
                } else if game.isSkunk {
                    stats.player2Skunks += 1
                }
            }
        }

        return stats
    }

    // MARK: - Player Stats

    /// Fetches complete statistics for a single player
    func statsForPlayer(_ player: Player) -> PlayerLeagueStats {
        return computeStats(for: player)
    }

    /// Fetches all opponents a player has played against
    func opponents(for player: Player) -> [Player] {
        var opponentSet = Set<UUID>()
        var opponents: [Player] = []

        let gamesWon = (player.gamesWon as? Set<Game>) ?? []
        let gamesLost = (player.gamesLost as? Set<Game>) ?? []

        for game in gamesWon {
            if let opponent = game.loserPlayer, let id = opponent.id, !opponentSet.contains(id) {
                opponentSet.insert(id)
                opponents.append(opponent)
            }
        }

        for game in gamesLost {
            if let opponent = game.winnerPlayer, let id = opponent.id, !opponentSet.contains(id) {
                opponentSet.insert(id)
                opponents.append(opponent)
            }
        }

        return opponents.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
