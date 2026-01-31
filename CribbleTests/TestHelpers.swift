//
//  TestHelpers.swift
//  CribbleTests
//
//  Test utilities for creating in-memory Core Data stacks
//

import CoreData
@testable import Cribble

/// A test-specific Core Data stack that uses an in-memory store
/// and skips migration logic
class TestCoreDataStack {
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    init() {
        container = NSPersistentContainer(name: "Cribble")

        // Use in-memory store
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        // Load synchronously for tests
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            fatalError("Failed to load test store: \(error)")
        }
    }
}

/// Creates a test game with specified scores
func createTestGame(
    in context: NSManagedObjectContext,
    winnerScore: Int16 = 121,
    loserScore: Int16 = 100,
    winner: Player? = nil,
    loser: Player? = nil
) -> Game {
    let game = Game(context: context)
    game.id = UUID()
    game.date = Date()
    game.winnerScore = winnerScore
    game.loserScore = loserScore
    game.winner = winner?.name ?? "Winner"
    game.loser = loser?.name ?? "Loser"
    game.duration = 1800
    game.winnerPlayer = winner
    game.loserPlayer = loser
    return game
}

/// Creates a test player
func createTestPlayer(in context: NSManagedObjectContext, name: String) -> Player {
    let player = Player(context: context)
    player.id = UUID()
    player.name = name
    player.createdAt = Date()
    return player
}
