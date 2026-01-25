//
//  Player+Extensions.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import CoreData

extension Player {

    /// Fetches an existing player by name (case-insensitive) or creates a new one
    static func fetchOrCreate(name: String, in context: NSManagedObjectContext) -> Player {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", normalizedName)
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let player = Player(context: context)
        player.id = UUID()
        player.name = normalizedName.isEmpty ? "Player" : normalizedName
        player.createdAt = Date()
        return player
    }

    /// Searches for players matching a query string (case-insensitive, contains match)
    static func searchPlayers(matching query: String, in context: NSManagedObjectContext) -> [Player] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fetchAllPlayers(in: context)
        }

        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Player.name, ascending: true)]
        request.fetchLimit = 10

        return (try? context.fetch(request)) ?? []
    }

    /// Fetches all players sorted by name
    static func fetchAllPlayers(in context: NSManagedObjectContext) -> [Player] {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Player.name, ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    /// Fetches a specific player by UUID
    static func fetchPlayer(id: UUID, in context: NSManagedObjectContext) -> Player? {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    /// Renames a player
    func rename(to newName: String, in context: NSManagedObjectContext) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        self.name = trimmed
        try? context.save()
    }

    /// Merges another player into this one (moves all games)
    func merge(from source: Player, in context: NSManagedObjectContext) {
        // Move all won games from source to this player
        if let sourceWonGames = source.gamesWon as? Set<Game> {
            for game in sourceWonGames {
                game.winnerPlayer = self
            }
        }

        // Move all lost games from source to this player
        if let sourceLostGames = source.gamesLost as? Set<Game> {
            for game in sourceLostGames {
                game.loserPlayer = self
            }
        }

        // Delete the source player
        context.delete(source)

        try? context.save()
    }

    /// Returns a display string with disambiguation if needed (for players with same name)
    var displayNameWithDate: String {
        guard let name = self.name, let createdAt = self.createdAt else {
            return "Unknown Player"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "\(name) (added \(formatter.string(from: createdAt)))"
    }

    /// Total games played by this player
    var totalGamesPlayed: Int {
        let won = (gamesWon as? Set<Game>)?.count ?? 0
        let lost = (gamesLost as? Set<Game>)?.count ?? 0
        return won + lost
    }

    /// Number of games won
    var totalWins: Int {
        return (gamesWon as? Set<Game>)?.count ?? 0
    }

    /// Number of games lost
    var totalLosses: Int {
        return (gamesLost as? Set<Game>)?.count ?? 0
    }

    /// Win percentage (0-100)
    var winPercentage: Double {
        let total = totalGamesPlayed
        guard total > 0 else { return 0 }
        return Double(totalWins) / Double(total) * 100
    }
}
