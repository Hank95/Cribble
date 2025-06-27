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
        
        let sampleGame = Game(context: viewContext)
        sampleGame.id = UUID()
        sampleGame.date = Date()
        sampleGame.winner = "Player 1"
        sampleGame.loser = "Player 2"
        sampleGame.winnerScore = 121
        sampleGame.loserScore = 95
        sampleGame.duration = 1800.0
        
        let stats1 = PlayerStats(context: viewContext)
        stats1.name = "Player 1"
        stats1.gamesPlayed = 1
        stats1.gamesWon = 1
        stats1.gamesLost = 0
        stats1.averageScore = 121.0
        
        let stats2 = PlayerStats(context: viewContext)
        stats2.name = "Player 2"
        stats2.gamesPlayed = 1
        stats2.gamesWon = 0
        stats2.gamesLost = 1
        stats2.averageScore = 95.0
        
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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func getUserSettings() -> UserSettings {
        return UserSettings.fetchOrCreate(in: container.viewContext)
    }
    
    func saveGame(winner: String, loser: String, winnerScore: Int16, loserScore: Int16, duration: Double? = nil) {
        let context = container.viewContext
        
        let game = Game(context: context)
        game.id = UUID()
        game.date = Date()
        game.winner = winner
        game.loser = loser
        game.winnerScore = winnerScore
        game.loserScore = loserScore
        game.duration = duration ?? 0.0
        
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
}
