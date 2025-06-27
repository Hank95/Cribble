import SwiftUI

struct DonationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingThankYou = false
    @State private var showingShareSheet = false
    @EnvironmentObject var userSettings: UserSettings
    
    private var selectedBackground: BackgroundStyle {
        let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
        return BackgroundStyle(rawValue: backgroundValue) ?? .classic
    }
    
    private let donationOptions = [
        DonationOption(
            title: "Buy Me a Coffee",
            subtitle: "Support with a virtual coffee",
            icon: "cup.and.saucer.fill",
            color: .orange,
            url: "https://coff.ee/henrypendleton",
            amount: "$5"
        ),
        DonationOption(
            title: "Ko-fi",
            subtitle: "One-time or monthly support",
            icon: "heart.fill",
            color: .red,
            url: "https://ko-fi.com/henrypendleton",
            amount: "$3+"
        ),
        DonationOption(
            title: "PayPal",
            subtitle: "Direct donation via PayPal",
            icon: "creditcard.fill",
            color: .blue,
            url: "https://paypal.me/henrypendleton",
            amount: "Any amount"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "suit.club.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .background(
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 100, height: 100)
                            )
                            .shadow(radius: 8)
                        
                        VStack(spacing: 8) {
                            Text("Support CribScore")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(selectedBackground.titleTextColor)
                                .multilineTextAlignment(.center)
                            
                            Text("Help keep the app free and improved")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Appreciation Message
                    VStack(spacing: 16) {
                        Text("♠️ Thank you for using CribScore!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedBackground.titleTextColor)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 12) {
                            Text("CribScore is crafted with love. Your support helps:")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                SupportBenefit(icon: "sparkles", text: "Keep the app free for everyone")
                                SupportBenefit(icon: "wrench.and.screwdriver", text: "Fund new features and improvements")
                                SupportBenefit(icon: "gamecontroller", text: "Add more game tracking options")
                                SupportBenefit(icon: "cup.and.saucer", text: "Fuel late-night coding sessions")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Donation Options
                    VStack(spacing: 16) {
                        SectionHeader(title: "Choose Your Support Level", titleColor: selectedBackground.titleTextColor)
                        
                        VStack(spacing: 12) {
                            ForEach(donationOptions, id: \.title) { option in
                                DonationOptionCard(option: option) {
                                    openDonationLink(option.url)
                                }
                            }
                        }
                    }
                    
                    // Alternative Support
                    VStack(spacing: 16) {
                        SectionHeader(title: "Other Ways to Help", titleColor: selectedBackground.titleTextColor)
                        
                        VStack(spacing: 12) {
                            AlternativeSupportCard(
                                icon: "star.fill",
                                title: "Rate the App",
                                subtitle: "Leave a review on the App Store",
                                color: .yellow
                            ) {
                                openAppStoreReview()
                            }
                            
                            AlternativeSupportCard(
                                icon: "person.2.fill",
                                title: "Share with Friends",
                                subtitle: "Tell others about CribScore",
                                color: .green
                            ) {
                                shareApp()
                            }
                            
                            AlternativeSupportCard(
                                icon: "envelope.fill",
                                title: "Send Feedback",
                                subtitle: "Help improve the app",
                                color: .blue
                            ) {
                                sendFeedback()
                            }
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Every contribution, big or small, is deeply appreciated!")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("- Henry, Developer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
            .background(.clear)
            .navigationTitle("Support")
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
        .sheet(isPresented: $showingThankYou) {
            ThankYouView()
                .environmentObject(userSettings)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: ["Check out CribScore - the perfect cribbage scoring companion! ♠️♥️♣️♦️"])
        }
    }
    
    private func openDonationLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
        
        // Show thank you after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingThankYou = true
        }
        
        // Haptic feedback if enabled
        if userSettings.enableHaptics {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    private func openAppStoreReview() {
        // Replace with your actual App Store ID when available
        guard let url = URL(string: "https://apps.apple.com/app/id[YOUR_APP_ID]?action=write-review") else { return }
        UIApplication.shared.open(url)
        
        if userSettings.enableHaptics {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
    
    private func shareApp() {
        showingShareSheet = true
        
        if userSettings.enableHaptics {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
    
    private func sendFeedback() {
        guard let url = URL(string: "mailto:hhpendleton@gmail.com?subject=CribScore%20Feedback") else { return }
        UIApplication.shared.open(url)
        
        if userSettings.enableHaptics {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
}

struct DonationOption {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let url: String
    let amount: String
}

struct DonationOptionCard: View {
    let option: DonationOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(option.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: option.icon)
                        .font(.title2)
                        .foregroundColor(option.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(option.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(option.amount)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(option.color)
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AlternativeSupportCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SupportBenefit: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct SectionHeader: View {
    let title: String
    let titleColor: Color
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(titleColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ThankYouView: View {
    @Environment(\.dismiss) var dismiss
    @State private var animate = false
    @EnvironmentObject var userSettings: UserSettings
    
    private var selectedBackground: BackgroundStyle {
        let backgroundValue = userSettings.selectedBackground ?? BackgroundStyle.classic.rawValue
        return BackgroundStyle(rawValue: backgroundValue) ?? .classic
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .scaleEffect(animate ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
                }
                
                VStack(spacing: 16) {
                    Text("Thank You! 🙏")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(selectedBackground.titleTextColor)
                    
                    VStack(spacing: 8) {
                        Text("Your support means the world!")
                            .font(.title3)
                            .foregroundColor(selectedBackground.titleTextColor)
                            .multilineTextAlignment(.center)
                        
                        Text("Every contribution helps keep CribScore growing and improving for everyone.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
            
            Button("Continue") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
        }
        .padding()
        .onAppear {
            animate = true
            
            if userSettings.enableHaptics {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DonationView()
        .environmentObject(UserSettings())
}