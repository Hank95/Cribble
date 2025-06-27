import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSettings: UserSettings
    @State private var currentPage = 0
    @State private var animateElements = false
    @State private var showScoreDial = false
    @State private var demoScore = 0
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            // Background that matches selected theme
            let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
            let currentBackground = BackgroundStyle(rawValue: backgroundValue) ?? .classic
            currentBackground.backgroundView
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Content area
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    welcomePage
                        .tag(0)
                    
                    // Page 2: Score Tracking
                    scoreTrackingPage
                        .tag(1)
                    
                    // Page 3: Features
                    featuresPage
                        .tag(2)
                    
                    // Page 4: Get Started
                    getStartedPage
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Navigation buttons
                navigationButtons
                    .padding()
            }
        }
        .onAppear {
            animateElements = true
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                // App icon animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateElements ? 1.0 : 0.8)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateElements)
                    
                    Image("AppImg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .scaleEffect(animateElements ? 1.0 : 0.5)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: animateElements)
                }
                
                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .opacity(animateElements ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateElements)
                    
                    Text("CribScore")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .opacity(animateElements ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.8), value: animateElements)
                    
                    Text("Your perfect cribbage scoring companion")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(animateElements ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: animateElements)
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    FeatureHighlight(icon: "gamecontroller.fill", text: "Easy Scoring", color: .blue)
                    FeatureHighlight(icon: "clock.fill", text: "Game History", color: .purple)
                }
                
                HStack(spacing: 16) {
                    FeatureHighlight(icon: "gearshape.fill", text: "Customizable", color: .orange)
                    FeatureHighlight(icon: "heart.fill", text: "Beautiful UI", color: .red)
                }
            }
            .opacity(animateElements ? 1.0 : 0.0)
            .offset(y: animateElements ? 0 : 30)
            .animation(.easeOut(duration: 0.8).delay(1.2), value: animateElements)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var scoreTrackingPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Intuitive Score Tracking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Use our custom score dial to quickly add points during gameplay")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Interactive demo dial
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    // Simplified score dial demo
                    ScoreDialDemo(score: $demoScore)
                        .frame(width: 180, height: 180)
                        .onAppear {
                            // Auto-demo animation
                            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    demoScore = [5, 10, 15, 2, 8][Int.random(in: 0...4)]
                                }
                            }
                        }
                }
                
                VStack(spacing: 8) {
                    Text("Selected: \(demoScore) points")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("Drag to select • Tap to confirm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 30) {
                OnboardingFeature(
                    icon: "hand.draw.fill",
                    title: "Drag & Drop",
                    description: "Smooth gesture controls"
                )
                
                OnboardingFeature(
                    icon: "waveform.circle.fill",
                    title: "Haptic Feedback",
                    description: "Feel every selection"
                )
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var featuresPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Powerful Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Everything you need for the perfect cribbage experience")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "paintbrush.fill",
                    iconColor: .purple,
                    title: "Beautiful Themes",
                    description: "Choose from felt green, midnight blue, warm gradients and more"
                )
                
                FeatureRow(
                    icon: "square.stack.3d.up.fill",
                    iconColor: .blue,
                    title: "Game History",
                    description: "Track all your games with detailed statistics and scores"
                )
                
                FeatureRow(
                    icon: "slider.horizontal.3",
                    iconColor: .green,
                    title: "Customizable Settings",
                    description: "Haptics, sounds, auto-save, and screen preferences"
                )
                
                FeatureRow(
                    icon: "book.fill",
                    iconColor: .orange,
                    title: "Built-in Rules",
                    description: "Complete cribbage rules reference right in the app"
                )
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var getStartedPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Ready to Play!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Start your first game and experience the smoothest cribbage scoring ever")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Demo game preview
            VStack(spacing: 16) {
                HStack {
                    DemoPlayerCard(name: "Player 1", score: 67, color: .blue, isWinning: true)
                    DemoPlayerCard(name: "Player 2", score: 43, color: .orange, isWinning: false)
                }
                
                Text("Race to 121 points!")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            
            VStack(spacing: 12) {
                Text("🎯 Quick Tips:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    TipRow(text: "Tap \"New Game\" to set up your first match")
                    TipRow(text: "Use the score dials to add points quickly")
                    TipRow(text: "Check Settings for themes and preferences")
                    TipRow(text: "View Rules anytime for complete instructions")
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentPage > 0 {
                Button("Previous") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage -= 1
                    }
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            if currentPage < totalPages - 1 {
                Button("Next") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
            } else {
                Button("Get Started") {
                    userSettings.hasSeenOnboarding = true
                    userSettings.save()
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(8)
            }
        }
    }
}

struct FeatureHighlight: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct DemoPlayerCard: View {
    let name: String
    let score: Int
    let color: Color
    let isWinning: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.headline)
                .foregroundColor(color)
            
            Text("\(score)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            if isWinning {
                Text("Leading!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct ScoreDialDemo: View {
    @Binding var score: Int
    @State private var angle: Double = 0
    
    var body: some View {
        ZStack {
            // Dial background
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
            
            // Score markings
            ForEach(1...15, id: \.self) { number in
                let markAngle = Double(number - 1) * (360.0 / 15.0) - 90
                
                VStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 2, height: number % 5 == 0 ? 20 : 12)
                    Spacer()
                }
                .rotationEffect(.degrees(markAngle))
            }
            
            // Current selection indicator
            VStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 30)
                Spacer()
            }
            .rotationEffect(.degrees(angle))
            
            // Center display
            VStack {
                Text("\(score)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: score) { _, newScore in
            withAnimation(.easeInOut(duration: 0.5)) {
                angle = Double(newScore) * (360.0 / 15.0) - 90
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserSettings())
}