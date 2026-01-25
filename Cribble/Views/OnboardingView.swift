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
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700

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
                    .padding(.top, isCompact ? 8 : 16)

                    // Content area
                    TabView(selection: $currentPage) {
                        // Page 1: Welcome
                        welcomePage(isCompact: isCompact, geometry: geometry)
                            .tag(0)

                        // Page 2: Score Tracking
                        scoreTrackingPage(isCompact: isCompact, geometry: geometry)
                            .tag(1)

                        // Page 3: Features
                        featuresPage(isCompact: isCompact)
                            .tag(2)

                        // Page 4: Get Started
                        getStartedPage(isCompact: isCompact)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentPage)

                    // Navigation buttons
                    navigationButtons(isCompact: isCompact)
                        .padding(isCompact ? 8 : 16)
                }
            }
        }
        .onAppear {
            animateElements = true
        }
    }
    
    private func welcomePage(isCompact: Bool, geometry: GeometryProxy) -> some View {
        let iconCircleSize: CGFloat = isCompact ? 80 : 120
        let appIconSize: CGFloat = isCompact ? 56 : 80
        let titleFont: Font = isCompact ? .title : .largeTitle
        let subtitleFont: Font = isCompact ? .subheadline : .title3
        let spacing: CGFloat = isCompact ? 20 : 40

        return ScrollView(showsIndicators: false) {
            VStack(spacing: spacing) {
                Spacer(minLength: isCompact ? 10 : 20)

                VStack(spacing: isCompact ? 12 : 20) {
                    // App icon animation
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: iconCircleSize, height: iconCircleSize)
                            .scaleEffect(animateElements ? 1.0 : 0.8)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateElements)

                        Image("AppImg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: appIconSize, height: appIconSize)
                            .clipShape(RoundedRectangle(cornerRadius: isCompact ? 12 : 16))
                            .scaleEffect(animateElements ? 1.0 : 0.5)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: animateElements)
                    }

                    VStack(spacing: isCompact ? 6 : 12) {
                        Text("Welcome to")
                            .font(isCompact ? .subheadline : .title2)
                            .foregroundColor(.secondary)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: animateElements)

                        Text("CribScore")
                            .font(titleFont)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(0.8), value: animateElements)

                        Text("Your perfect cribbage scoring companion")
                            .font(subtitleFont)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(1.0), value: animateElements)
                    }
                }

                Spacer(minLength: isCompact ? 10 : 20)

                // Use adaptive grid for feature highlights
                LazyVGrid(columns: [GridItem(.adaptive(minimum: isCompact ? 140 : 160))], spacing: isCompact ? 8 : 16) {
                    FeatureHighlight(icon: "gamecontroller.fill", text: "Easy Scoring", color: .blue, isCompact: isCompact)
                    FeatureHighlight(icon: "clock.fill", text: "Game History", color: .purple, isCompact: isCompact)
                    FeatureHighlight(icon: "gearshape.fill", text: "Customizable", color: .orange, isCompact: isCompact)
                    FeatureHighlight(icon: "heart.fill", text: "Beautiful UI", color: .red, isCompact: isCompact)
                }
                .opacity(animateElements ? 1.0 : 0.0)
                .offset(y: animateElements ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(1.2), value: animateElements)

                Spacer(minLength: isCompact ? 10 : 20)
            }
            .padding(.horizontal)
            .frame(minHeight: geometry.size.height - 100) // Account for progress bar and nav buttons
        }
    }
    
    private func scoreTrackingPage(isCompact: Bool, geometry: GeometryProxy) -> some View {
        let dialSize: CGFloat = isCompact ? 140 : 200
        let dialInnerSize: CGFloat = isCompact ? 120 : 180
        let titleFont: Font = isCompact ? .title2 : .largeTitle
        let spacing: CGFloat = isCompact ? 20 : 40

        return ScrollView(showsIndicators: false) {
            VStack(spacing: spacing) {
                Spacer(minLength: isCompact ? 10 : 20)

                VStack(spacing: isCompact ? 10 : 20) {
                    Text("Intuitive Score Tracking")
                        .font(titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("Use our custom score dial to quickly add points during gameplay")
                        .font(isCompact ? .subheadline : .title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Interactive demo dial
                VStack(spacing: isCompact ? 12 : 20) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: dialSize, height: dialSize)

                        // Simplified score dial demo
                        ScoreDialDemo(score: $demoScore)
                            .frame(width: dialInnerSize, height: dialInnerSize)
                            .onAppear {
                                // Auto-demo animation
                                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        demoScore = [5, 10, 15, 2, 8][Int.random(in: 0...4)]
                                    }
                                }
                            }
                    }

                    VStack(spacing: isCompact ? 4 : 8) {
                        Text("Selected: \(demoScore) points")
                            .font(isCompact ? .subheadline : .headline)
                            .foregroundColor(.blue)

                        Text("Drag to select • Tap to confirm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer(minLength: isCompact ? 10 : 20)

                // Use adaptive layout for features
                LazyVGrid(columns: [GridItem(.adaptive(minimum: isCompact ? 130 : 150))], spacing: isCompact ? 8 : 16) {
                    OnboardingFeature(
                        icon: "hand.draw.fill",
                        title: "Drag & Drop",
                        description: "Smooth gesture controls",
                        isCompact: isCompact
                    )

                    OnboardingFeature(
                        icon: "waveform.circle.fill",
                        title: "Haptic Feedback",
                        description: "Feel every selection",
                        isCompact: isCompact
                    )
                }

                Spacer(minLength: isCompact ? 10 : 20)
            }
            .padding(.horizontal)
            .frame(minHeight: geometry.size.height - 100)
        }
    }
    
    private func featuresPage(isCompact: Bool) -> some View {
        let titleFont: Font = isCompact ? .title2 : .largeTitle
        let spacing: CGFloat = isCompact ? 16 : 24

        return ScrollView(showsIndicators: false) {
            VStack(spacing: isCompact ? 20 : 40) {
                Spacer(minLength: isCompact ? 10 : 20)

                VStack(spacing: isCompact ? 10 : 20) {
                    Text("Powerful Features")
                        .font(titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Everything you need for the perfect cribbage experience")
                        .font(isCompact ? .subheadline : .title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: spacing) {
                    FeatureRow(
                        icon: "paintbrush.fill",
                        iconColor: .purple,
                        title: "Beautiful Themes",
                        description: "Choose from felt green, midnight blue, warm gradients and more",
                        isCompact: isCompact
                    )

                    FeatureRow(
                        icon: "square.stack.3d.up.fill",
                        iconColor: .blue,
                        title: "Game History",
                        description: "Track all your games with detailed statistics and scores",
                        isCompact: isCompact
                    )

                    FeatureRow(
                        icon: "slider.horizontal.3",
                        iconColor: .green,
                        title: "Customizable Settings",
                        description: "Haptics, sounds, auto-save, and screen preferences",
                        isCompact: isCompact
                    )

                    FeatureRow(
                        icon: "book.fill",
                        iconColor: .orange,
                        title: "Built-in Rules",
                        description: "Complete cribbage rules reference right in the app",
                        isCompact: isCompact
                    )
                }

                Spacer(minLength: isCompact ? 10 : 20)
            }
            .padding(.horizontal)
        }
    }
    
    private func getStartedPage(isCompact: Bool) -> some View {
        let titleFont: Font = isCompact ? .title2 : .largeTitle

        return ScrollView(showsIndicators: false) {
            VStack(spacing: isCompact ? 20 : 40) {
                Spacer(minLength: isCompact ? 10 : 20)

                VStack(spacing: isCompact ? 10 : 20) {
                    Text("Ready to Play!")
                        .font(titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Start your first game and experience the smoothest cribbage scoring ever")
                        .font(isCompact ? .subheadline : .title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Demo game preview
                VStack(spacing: isCompact ? 8 : 16) {
                    HStack(spacing: isCompact ? 8 : 16) {
                        DemoPlayerCard(name: "Player 1", score: 67, color: .blue, isWinning: true, isCompact: isCompact)
                        DemoPlayerCard(name: "Player 2", score: 43, color: .orange, isWinning: false, isCompact: isCompact)
                    }

                    Text("Race to 121 points!")
                        .font(isCompact ? .subheadline : .headline)
                        .foregroundColor(.blue)
                }
                .padding(isCompact ? 8 : 16)
                .background(Color(.systemGray6))
                .cornerRadius(isCompact ? 12 : 16)

                VStack(spacing: isCompact ? 8 : 12) {
                    Text("🎯 Quick Tips:")
                        .font(isCompact ? .subheadline : .headline)
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
                        TipRow(text: "Tap \"New Game\" to set up your first match", isCompact: isCompact)
                        TipRow(text: "Use the score dials to add points quickly", isCompact: isCompact)
                        TipRow(text: "Check Settings for themes and preferences", isCompact: isCompact)
                        TipRow(text: "View Rules anytime for complete instructions", isCompact: isCompact)
                    }
                }

                Spacer(minLength: isCompact ? 10 : 20)
            }
            .padding(.horizontal)
        }
    }
    
    private func navigationButtons(isCompact: Bool) -> some View {
        HStack {
            if currentPage > 0 {
                Button("Previous") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage -= 1
                    }
                }
                .font(isCompact ? .subheadline : .body)
                .foregroundColor(.blue)
            }

            Spacer()

            if currentPage < totalPages - 1 {
                Button("Next") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                }
                .font(isCompact ? .subheadline : .body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, isCompact ? 16 : 24)
                .padding(.vertical, isCompact ? 8 : 12)
                .background(Color.blue)
                .cornerRadius(8)
            } else {
                Button("Get Started") {
                    userSettings.hasSeenOnboarding = true
                    userSettings.save()
                    dismiss()
                }
                .font(isCompact ? .subheadline : .body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, isCompact ? 16 : 24)
                .padding(.vertical, isCompact ? 8 : 12)
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
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: isCompact ? 4 : 8) {
            Image(systemName: icon)
                .font(isCompact ? .body : .title2)
                .foregroundColor(color)
                .frame(width: isCompact ? 32 : 40, height: isCompact ? 32 : 40)
                .background(color.opacity(0.1))
                .cornerRadius(isCompact ? 6 : 8)

            Text(text)
                .font(isCompact ? .caption2 : .caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: isCompact ? 6 : 12) {
            Image(systemName: icon)
                .font(isCompact ? .title3 : .title)
                .foregroundColor(.blue)

            Text(title)
                .font(isCompact ? .subheadline : .headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(description)
                .font(isCompact ? .caption2 : .caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: isCompact ? 10 : 16) {
            Image(systemName: icon)
                .font(isCompact ? .body : .title2)
                .foregroundColor(iconColor)
                .frame(width: isCompact ? 32 : 40, height: isCompact ? 32 : 40)
                .background(iconColor.opacity(0.1))
                .cornerRadius(isCompact ? 6 : 8)

            VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                Text(title)
                    .font(isCompact ? .subheadline : .headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(description)
                    .font(isCompact ? .caption : .subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
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
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: isCompact ? 4 : 8) {
            Text(name)
                .font(isCompact ? .subheadline : .headline)
                .foregroundColor(color)
                .lineLimit(1)

            Text("\(score)")
                .font(.system(size: isCompact ? 24 : 32, weight: .bold))
                .foregroundColor(color)

            if isWinning {
                Text("Leading!")
                    .font(isCompact ? .caption2 : .caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 8 : 16)
        .background(color.opacity(0.1))
        .cornerRadius(isCompact ? 8 : 12)
    }
}

struct TipRow: View {
    let text: String
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: isCompact ? 6 : 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(isCompact ? .caption2 : .caption)
                .foregroundColor(.green)

            Text(text)
                .font(isCompact ? .caption : .subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

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