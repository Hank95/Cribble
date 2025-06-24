import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            TabView {
                MainGameView()
                    .tabItem {
                        Image(systemName: "gamecontroller.fill")
                        Text("Game")
                    }
                
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }
            }
            .accentColor(.blue)
            
            // Progress ring overlay
            ScoringOverlayView(gameViewModel: gameViewModel)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(GameViewModel())
}