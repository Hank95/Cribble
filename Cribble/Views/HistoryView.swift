import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.date, ascending: false)],
        animation: .default)
    private var games: FetchedResults<Game>
    
    var body: some View {
        NavigationView {
            List {
                if games.isEmpty {
                    Text("No games played yet")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(games) { game in
                        GameRowView(game: game)
                    }
                    .onDelete(perform: deleteGames)
                }
            }
            .navigationTitle("Game History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteGames(offsets: IndexSet) {
        withAnimation {
            offsets.map { games[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Failed to delete games: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct GameRowView: View {
    let game: Game
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(game.winner ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Winner")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(game.winnerScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("-")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("\(game.loserScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(game.loser ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Loser")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(dateFormatter.string(from: game.date ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if game.duration > 0 {
                    Text("Duration: \(durationFormatter.string(from: game.duration) ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}