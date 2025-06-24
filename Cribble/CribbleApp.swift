//
//  CribbleApp.swift
//  Cribble
//
//  Created by Henry Pendleton on 6/24/25.
//

import SwiftUI

@main
struct CribbleApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var gameViewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(gameViewModel)
        }
    }
}
