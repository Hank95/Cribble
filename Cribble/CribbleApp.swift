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
    @AppStorage("keepScreenOn") private var keepScreenOn = false
    @AppStorage("selectedBackground") private var selectedBackgroundRaw = BackgroundStyle.classic.rawValue

    private var selectedBackground: BackgroundStyle {
        BackgroundStyle(rawValue: selectedBackgroundRaw) ?? .classic
    }
    
    init() {
        // Apply screen idle timer setting on app launch
        UIApplication.shared.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: "keepScreenOn")
        
        // Configure appearance for transparent navigation
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        
        // Make table/list backgrounds transparent
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Apply background at the root level
                selectedBackground.backgroundView
                
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(gameViewModel)
            }
            .onAppear {
                // Ensure the setting is applied when app becomes active
                UIApplication.shared.isIdleTimerDisabled = keepScreenOn
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Reapply setting when app comes to foreground
                UIApplication.shared.isIdleTimerDisabled = keepScreenOn
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                // Reset idle timer when app goes to background
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}
