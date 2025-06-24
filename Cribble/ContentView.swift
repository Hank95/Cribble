//
//  ContentView.swift
//  Cribble
//
//  Created by Henry Pendleton on 6/24/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        MainGameView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(GameViewModel())
}
