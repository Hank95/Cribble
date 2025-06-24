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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
