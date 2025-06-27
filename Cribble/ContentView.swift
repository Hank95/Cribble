//
//  ContentView.swift
//  Cribble
//
//  Created by Henry Pendleton on 6/24/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            MainTabView()
                .environmentObject(gameViewModel)
            
            // Progress ring overlay
            ScoringOverlayView(gameViewModel: gameViewModel)
                .ignoresSafeArea()
        }
        .background(Color.clear)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
