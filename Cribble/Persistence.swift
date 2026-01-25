//
//  Persistence.swift
//  Cribble
//
//  Created by Henry Pendleton on 6/24/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample Players
        let player1 = Player(context: viewContext)
        player1.id = UUID()
        player1.name = "Alice"
        player1.createdAt = Date()
        player1.preferredColor = "blue"

        let player2 = Player(context: viewContext)
        player2.id = UUID()
        player2.name = "Bob"
        player2.createdAt = Date()
        player2.preferredColor = "orange"

        let player3 = Player(context: viewContext)
        player3.id = UUID()
        player3.name = "Charlie"
        player3.createdAt = Date()
        player3.preferredColor = "green"

        // Create sample games with Player relationships
        let sampleGame1 = Game(context: viewContext)
        sampleGame1.id = UUID()
        sampleGame1.date = Date()
        sampleGame1.winner = "Alice"
        sampleGame1.loser = "Bob"
        sampleGame1.winnerScore = 121
        sampleGame1.loserScore = 95
        sampleGame1.duration = 1800.0
        sampleGame1.winnerPlayer = player1
        sampleGame1.loserPlayer = player2

        let sampleGame2 = Game(context: viewContext)
        sampleGame2.id = UUID()
        sampleGame2.date = Date().addingTimeInterval(-86400) // Yesterday
        sampleGame2.winner = "Bob"
        sampleGame2.loser = "Alice"
        sampleGame2.winnerScore = 121
        sampleGame2.loserScore = 58 // Double skunk!
        sampleGame2.duration = 1200.0
        sampleGame2.winnerPlayer = player2
        sampleGame2.loserPlayer = player1

        let sampleGame3 = Game(context: viewContext)
        sampleGame3.id = UUID()
        sampleGame3.date = Date().addingTimeInterval(-172800) // 2 days ago
        sampleGame3.winner = "Alice"
        sampleGame3.loser = "Charlie"
        sampleGame3.winnerScore = 121
        sampleGame3.loserScore = 85 // Skunk
        sampleGame3.duration = 2100.0
        sampleGame3.winnerPlayer = player1
        sampleGame3.loserPlayer = player3

        // Legacy PlayerStats (deprecated but kept for compatibility)
        let stats1 = PlayerStats(context: viewContext)
        stats1.name = "Alice"
        stats1.gamesPlayed = 3
        stats1.gamesWon = 2
        stats1.gamesLost = 1
        stats1.averageScore = 100.0

        let stats2 = PlayerStats(context: viewContext)
        stats2.name = "Bob"
        stats2.gamesPlayed = 2
        stats2.gamesWon = 1
        stats2.gamesLost = 1
        stats2.averageScore = 108.0

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cribble")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable lightweight migration
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Migrate existing games to use Player entities
        migrateExistingGamesToPlayers()
    }
    
    func getUserSettings() -> UserSettings {
        return UserSettings.fetchOrCreate(in: container.viewContext)
    }
    
    func saveGame(
        winner: String,
        loser: String,
        winnerScore: Int16,
        loserScore: Int16,
        duration: Double? = nil,
        winnerPlayer: Player? = nil,
        loserPlayer: Player? = nil
    ) {
        let context = container.viewContext

        let game = Game(context: context)
        game.id = UUID()
        game.date = Date()
        game.winner = winner
        game.loser = loser
        game.winnerScore = winnerScore
        game.loserScore = loserScore
        game.duration = duration ?? 0.0

        // Link to Player entities if provided, otherwise create/fetch them
        if let wp = winnerPlayer {
            game.winnerPlayer = wp
        } else {
            game.winnerPlayer = Player.fetchOrCreate(name: winner, in: context)
        }

        if let lp = loserPlayer {
            game.loserPlayer = lp
        } else {
            game.loserPlayer = Player.fetchOrCreate(name: loser, in: context)
        }

        // Update legacy PlayerStats (will be deprecated)
        updatePlayerStats(playerName: winner, won: true, score: winnerScore, context: context)
        updatePlayerStats(playerName: loser, won: false, score: loserScore, context: context)

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Failed to save game: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func updatePlayerStats(playerName: String, won: Bool, score: Int16, context: NSManagedObjectContext) {
        let request: NSFetchRequest<PlayerStats> = PlayerStats.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", playerName)
        
        do {
            let results = try context.fetch(request)
            let playerStats: PlayerStats
            
            if let existingStats = results.first {
                playerStats = existingStats
            } else {
                playerStats = PlayerStats(context: context)
                playerStats.name = playerName
                playerStats.gamesPlayed = 0
                playerStats.gamesWon = 0
                playerStats.gamesLost = 0
                playerStats.averageScore = 0.0
            }
            
            let previousTotalScore = playerStats.averageScore * Double(playerStats.gamesPlayed)
            playerStats.gamesPlayed += 1
            
            if won {
                playerStats.gamesWon += 1
            } else {
                playerStats.gamesLost += 1
            }
            
            let newTotalScore = previousTotalScore + Double(score)
            playerStats.averageScore = newTotalScore / Double(playerStats.gamesPlayed)
            
        } catch {
            let nsError = error as NSError
            print("Failed to update player stats: \(nsError), \(nsError.userInfo)")
        }
    }

    /// Migrates existing games that don't have Player relationships to use them
    private func migrateExistingGamesToPlayers() {
        let context = container.viewContext

        // Fetch games without winnerPlayer set
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        request.predicate = NSPredicate(format: "winnerPlayer == nil")

        do {
            let gamesToMigrate = try context.fetch(request)

            guard !gamesToMigrate.isEmpty else { return }

            print("Migrating \(gamesToMigrate.count) games to use Player entities...")

            for game in gamesToMigrate {
                // Create or fetch Player for winner
                if let winnerName = game.winner {
                    game.winnerPlayer = Player.fetchOrCreate(name: winnerName, in: context)
                }

                // Create or fetch Player for loser
                if let loserName = game.loser {
                    game.loserPlayer = Player.fetchOrCreate(name: loserName, in: context)
                }
            }

            try context.save()
            print("Migration completed successfully.")

        } catch {
            let nsError = error as NSError
            print("Failed to migrate games: \(nsError), \(nsError.userInfo)")
        }
    }
}
