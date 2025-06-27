import SwiftUI

struct CribbageRulesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSettings: UserSettings
    
    private var selectedBackground: BackgroundStyle {
        let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
        return BackgroundStyle(rawValue: backgroundValue) ?? .classic
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header and Credits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Six Card Cribbage Rules")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(selectedBackground.titleTextColor)
                            .padding(.bottom, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Source: pagat.com")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                if let url = URL(string: "https://www.pagat.com/adders/crib6.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("https://www.pagat.com/adders/crib6.html")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                            
                            Text("Originally based on contributions from Mike Block, David Dailey, John McLeod and many others.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Introduction
                    RuleSection(title: "Introduction") {
                        Text("Six Card Cribbage is basically a game for two players, but adapts easily for three players, and for four players in fixed partnerships - a very useful feature. It is now the standard form of Cribbage and widely played in English speaking parts of the world.")
                        
                        Text("Cribbage in England is primarily a pub game - indeed, it is one of the few games allowed by Statute to be played in a public house for small stakes. A game of low animal cunning where players must balance a number of different objectives, remain quick witted enough to recognise combinations, and be able to add up.")
                        
                        Text("It is also a game where etiquette is important. The rituals associated with cutting and dealing, playing and pegging, as well as the terminology, all serve the useful purpose of keeping things in order.")
                    }
                    
                    // Two-handed play
                    RuleSection(title: "Two-Handed Play") {
                        Text("Two players use a standard 52 card pack. Cards rank K(high) Q J 10 9 8 7 6 5 4 3 2 A(low).")
                            .fontWeight(.medium)
                    }
                    
                    // Object
                    RuleSection(title: "Object") {
                        Text("To be the first to score 121 points or over (twice round the usual British design of board) accumulated over several deals. Points are scored mainly for combinations of cards either occurring during the play or occurring in a player's hand or in the cards discarded before the play, which form the crib or box.")
                    }
                    
                    // Deal
                    RuleSection(title: "Deal") {
                        Text("The first deal is determined by cutting the cards. The player cutting the lower card deals and has the first box or crib. If the cards are equal - and that includes both players cutting a ten card (10, J, Q or K) - there is another cut for first deal.")
                        
                        Text("The dealer shuffles, the non-dealer cuts the cards, and dealer deals 6 cards face down to each player one at a time. The undealt part of the pack is placed face down on the table.")
                    }
                    
                    // Discard
                    RuleSection(title: "Discard") {
                        Text("Each player chooses two cards to discard face down to form the crib. These four cards are set aside until the end of the hand. The crib will count for the dealer - non-dealer will try to throw cards that are unlikely to make valuable combinations, but must balance this against keeping a good hand for himself.")
                    }
                    
                    // Start Card
                    RuleSection(title: "Start Card") {
                        Text("Non-dealer cuts the stack of undealt cards, lifting the upper part without showing its bottom card. The dealer takes out the top card of the lower part, turns it face up and places it face up on top of the pack. This turned up card is called the start card.")
                        
                        HighlightBox {
                            Text("If the start card is a jack, the dealer immediately pegs 2 holes - this is called \"Two for his heels\".")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Play of the cards
                    RuleSection(title: "Play of the Cards") {
                        Text("Beginning with the non-dealer, the players take turns to play single cards. The total pip value of the cards played by both players is counted, starting from zero and adding the value of each card as it is played. This total must not exceed 31.")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Values:")
                                .fontWeight(.semibold)
                            Text("• Ace = 1")
                            Text("• 2 to 10 = face value")
                            Text("• Jack = 10")
                            Text("• Queen = 10")
                            Text("• King = 10")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        Text("As each card is played, the player announces the running total. If a card is played which brings the total exactly to 31, the player pegs 2 claiming \"Thirty one for two\".")
                        
                        Text("A player who cannot play without exceeding 31 does not play a card but says \"Go\", leaving his opponent to continue if possible. The last player to lay a card pegs one for the go or one for last.")
                    }
                    
                    // Scoring during play
                    RuleSection(title: "Scoring During Play") {
                        VStack(alignment: .leading, spacing: 12) {
                            ScoringRule(title: "Fifteen (2 points)", description: "Playing a card that brings the total to 15")
                            ScoringRule(title: "Thirty-One (2 points)", description: "Playing a card that brings the total to exactly 31")
                            ScoringRule(title: "Pair (2 points)", description: "Playing a card of the same rank as the previous card")
                            ScoringRule(title: "Pair Royal (6 points)", description: "Third card of the same rank played immediately after a pair")
                            ScoringRule(title: "Double Pair Royal (12 points)", description: "Four cards of the same rank in immediate succession")
                            ScoringRule(title: "Run (variable points)", description: "3 or more consecutive cards. Score equals number of cards in run")
                            ScoringRule(title: "Last Card (1 point)", description: "Playing the last card when total is 30 or less")
                        }
                    }
                    
                    // The Show
                    RuleSection(title: "The Show") {
                        Text("Players now retrieve their cards and score for combinations in hand. The start card also counts as part of the hand when scoring combinations.")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ScoringRule(title: "Fifteen (2 points each)", description: "Any combination of cards adding up to 15 pips")
                            ScoringRule(title: "Pair (2 points)", description: "Two cards of the same rank. Three cards = 6 points, four cards = 12 points")
                            ScoringRule(title: "Run (variable points)", description: "Three or more consecutive cards. Score equals number of cards")
                            ScoringRule(title: "Flush (4 or 5 points)", description: "All hand cards same suit (4 pts). Include start card for 5 points")
                            ScoringRule(title: "One For His Nob (1 point)", description: "Jack in hand matching start card suit")
                        }
                        
                        HighlightBox {
                            Text("\"Nineteen\" - It is impossible to score nineteen in hand or crib. This term indicates a worthless hand.")
                                .italic()
                        }
                    }
                    
                    // Winning
                    RuleSection(title: "Winning the Game") {
                        Text("As soon as someone reaches or passes 121 points, that player wins the game. This can happen at any stage - during the play or the show, or even by dealer scoring two for his heels.")
                        
                        Text("It is not necessary to reach 121 exactly - you can win by scoring more when you were on 120. All that matters is that your opponent's pegs are both still on the board.")
                    }
                    
                    // Multi-player variations
                    RuleSection(title: "Multi-Player Variations") {
                        VStack(alignment: .leading, spacing: 12) {
                            SubSection(title: "Four-Handed Play") {
                                Text("Partners sit opposite each other. Cards are dealt clockwise one at a time, five to each player. Each player puts one card in the dealer's crib. Partners may help each other keep score and will try to assist each other during play.")
                            }
                            
                            SubSection(title: "Three-Handed Play") {
                                Text("Dealer deals five cards to each player and one into the crib. Each player discards one card, so everyone has a four-card hand. Each player acts completely independently.")
                            }
                        }
                    }
                    
                    // Footer spacing
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(.clear)
            .navigationTitle("Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(selectedBackground.titleTextColor)
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
        }
    }
}

struct RuleSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
    }
}

struct SubSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            content
        }
    }
}

struct ScoringRule: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct HighlightBox<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

#Preview {
    CribbageRulesView()
        .environmentObject(UserSettings())
}