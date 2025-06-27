import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        TabView {
            MainGameView()
                .background(Color.clear)
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Game")
                }
            
            HistoryView()
                .background(Color.clear)
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
        }
        .background(Color.clear)
        .accentColor(.blue)
        .toolbarBackground(.clear, for: .tabBar)
        .onAppear {
            // Make TabView background transparent
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(GameViewModel())
}