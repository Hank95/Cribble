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
    @StateObject private var userSettings: UserSettings
    @State private var initialBackground: BackgroundStyle
    
    init() {
        let persistenceController = PersistenceController.shared
        let settings = persistenceController.getUserSettings()
        _userSettings = StateObject(wrappedValue: settings)
        
        // Set initial background immediately
        let backgroundValue = settings.selectedBackground ?? BackgroundStyle.classic.rawValue
        let resolvedBackground = BackgroundStyle(rawValue: backgroundValue) ?? .classic
        _initialBackground = State(initialValue: resolvedBackground)
        
        // Apply screen idle timer setting on app launch
        UIApplication.shared.isIdleTimerDisabled = settings.keepScreenOn
        
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
        
        // Make tab bar transparent
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = .clear
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Use dynamic background at the very top level
                let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
                let currentBackground = BackgroundStyle(rawValue: backgroundValue) ?? .classic
                currentBackground.backgroundView
                
                BackgroundContainerView(
                    userSettings: userSettings,
                    persistenceController: persistenceController,
                    gameViewModel: gameViewModel,
                    initialBackground: initialBackground
                )
                .background(.clear)
            }
        }
    }
}

struct BackgroundContainerView: View {
    @ObservedObject var userSettings: UserSettings
    let persistenceController: PersistenceController
    let gameViewModel: GameViewModel
    let initialBackground: BackgroundStyle
    @State private var showingOnboarding = false
    
    var body: some View {
        let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
        let currentBackground = BackgroundStyle(rawValue: backgroundValue) ?? .classic
        
        ContentView()
            .background(.clear)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(gameViewModel)
            .environmentObject(userSettings)
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView()
                    .environmentObject(userSettings)
            }
            .onAppear {
                // Check if we should show onboarding
                if !userSettings.hasSeenOnboarding {
                    showingOnboarding = true
                }
                
                // Ensure the setting is applied when app becomes active
                UIApplication.shared.isIdleTimerDisabled = userSettings.keepScreenOn
                
                // Apply background at window level as well
                applyBackgroundToWindow(currentBackground)
            }
            .onChange(of: currentBackground) { _, newBackground in
                applyBackgroundToWindow(newBackground)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Reapply setting when app comes to foreground
                UIApplication.shared.isIdleTimerDisabled = userSettings.keepScreenOn
                applyBackgroundToWindow(currentBackground)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                // Reset idle timer when app goes to background
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
    
    private func applyBackgroundToWindow(_ background: BackgroundStyle) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            // Set window background color directly
            switch background {
            case .classic:
                window.backgroundColor = UIColor.systemBackground
            case .feltGreen:
                window.backgroundColor = UIColor(red: 0.18, green: 0.35, blue: 0.25, alpha: 1.0)
            case .midnightBlue:
                window.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
            case .warmGradient:
                window.backgroundColor = UIColor(red: 0.85, green: 0.65, blue: 0.55, alpha: 1.0)
            case .coolGradient:
                window.backgroundColor = UIColor(red: 0.45, green: 0.65, blue: 0.85, alpha: 1.0)
            case .subtlePattern:
                window.backgroundColor = UIColor.systemBackground
            }
            
            // Force root view controller to be transparent
            if let rootViewController = window.rootViewController {
                rootViewController.view.backgroundColor = .clear
                
                // Make all child view controllers transparent too
                func makeTransparent(_ vc: UIViewController) {
                    vc.view.backgroundColor = .clear
                    for child in vc.children {
                        makeTransparent(child)
                    }
                }
                makeTransparent(rootViewController)
            }
            
        }
    }
}
