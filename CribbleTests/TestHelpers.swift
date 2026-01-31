//
//  TestHelpers.swift
//  CribbleTests
//
//  Test utilities for creating in-memory Core Data stacks
//

import CoreData
@testable import Cribble

/// Shared managed object model to avoid "Multiple NSEntityDescriptions" errors
/// when creating multiple test containers
private let sharedManagedObjectModel: NSManagedObjectModel = {
    // Find the model in the main app bundle
    guard let modelURL = Bundle.main.url(forResource: "Cribble", withExtension: "momd") ??
                         Bundle(identifier: "com.henrypendleton.Cribble")?.url(forResource: "Cribble", withExtension: "momd") else {
        // Fallback: search all bundles
        for bundle in Bundle.allBundles {
            if let url = bundle.url(forResource: "Cribble", withExtension: "momd") {
                return NSManagedObjectModel(contentsOf: url)!
            }
        }
        fatalError("Failed to find Core Data model 'Cribble.momd' in any bundle")
    }
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
        fatalError("Failed to load Core Data model from \(modelURL)")
    }
    return model
}()

/// A test-specific Core Data stack that uses an in-memory store
/// and shares the managed object model to avoid entity conflicts
class TestCoreDataStack {
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    init() {
        // Use the shared model to avoid multiple entity description conflicts
        container = NSPersistentContainer(name: "Cribble", managedObjectModel: sharedManagedObjectModel)

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
