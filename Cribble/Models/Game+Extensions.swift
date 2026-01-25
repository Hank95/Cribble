//
//  Game+Extensions.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import CoreData

extension Game {

    /// Whether the loser was skunked (scored less than 91 points)
    /// Note: A game is a skunk if loser < 91 but not a double skunk
    var isSkunk: Bool {
        return loserScore < 91 && loserScore >= 61
    }

    /// Whether the loser was double skunked (scored less than 61 points)
    var isDoubleSkunk: Bool {
        return loserScore < 61
    }

    /// Match points earned by the winner
    /// - Double skunk: 3 points
    /// - Skunk: 2 points
    /// - Regular win: 1 point
    var matchPoints: Int {
        if isDoubleSkunk { return 3 }
        if isSkunk { return 2 }
        return 1
    }

    /// The margin of victory (winner score - loser score)
    var margin: Int {
        return Int(winnerScore) - Int(loserScore)
    }

    /// Formatted duration string (e.g., "15m" or "1h 23m")
    var formattedDuration: String {
        let totalMinutes = Int(duration / 60)
        if totalMinutes < 60 {
            return "\(totalMinutes)m"
        }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
    }

    /// Returns the winner's display name (from Player relationship or legacy string)
    var winnerDisplayName: String {
        return winnerPlayer?.name ?? winner ?? "Unknown"
    }

    /// Returns the loser's display name (from Player relationship or legacy string)
    var loserDisplayName: String {
        return loserPlayer?.name ?? loser ?? "Unknown"
    }

    /// Checks if a specific player won this game
    func wasWonBy(player: Player) -> Bool {
        return winnerPlayer?.id == player.id
    }

    /// Checks if a specific player lost this game
    func wasLostBy(player: Player) -> Bool {
        return loserPlayer?.id == player.id
    }

    /// Checks if a specific player participated in this game
    func includes(player: Player) -> Bool {
        return wasWonBy(player: player) || wasLostBy(player: player)
    }

    /// Fetches all games between two specific players
    static func gamesBetween(player1: Player, player2: Player, in context: NSManagedObjectContext) -> [Game] {
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "winnerPlayer == %@", player1),
                NSPredicate(format: "loserPlayer == %@", player2)
            ]),
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "winnerPlayer == %@", player2),
                NSPredicate(format: "loserPlayer == %@", player1)
            ])
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Game.date, ascending: false)]

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches all games for a specific player (won or lost)
    static func games(for player: Player, in context: NSManagedObjectContext) -> [Game] {
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "winnerPlayer == %@", player),
            NSPredicate(format: "loserPlayer == %@", player)
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Game.date, ascending: false)]

        return (try? context.fetch(request)) ?? []
    }
}
