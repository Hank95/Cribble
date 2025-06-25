import SwiftUI

struct SettingsView: View {
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("enableSounds") private var enableSounds = true
    @AppStorage("showExtendedScoreIndicator") private var showExtendedScoreIndicator = true
    @AppStorage("autoSaveGames") private var autoSaveGames = true
    @AppStorage("keepScreenOn") private var keepScreenOn = false
    @AppStorage("selectedBackground") private var selectedBackgroundRaw = BackgroundStyle.classic.rawValue
    
    @Environment(\.presentationMode) var presentationMode
    
    private var selectedBackground: BackgroundStyle {
        get { BackgroundStyle(rawValue: selectedBackgroundRaw) ?? .classic }
        set { selectedBackgroundRaw = newValue.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Options")) {
                    Toggle("Haptic Feedback", isOn: $enableHaptics)
                    Toggle("Sound Effects", isOn: $enableSounds)
                    Toggle("Show Extended Score Indicator", isOn: $showExtendedScoreIndicator)
                    Toggle("Auto-Save Completed Games", isOn: $autoSaveGames)
                }
                
                Section(header: Text("Display")) {
                    Toggle("Keep Screen On", isOn: $keepScreenOn)
                        .onChange(of: keepScreenOn) { _, newValue in
                            UIApplication.shared.isIdleTimerDisabled = newValue
                        }
                }
                
                Section(header: Text("Background Theme")) {
                    BackgroundSelectionGrid(selectedBackgroundRaw: $selectedBackgroundRaw)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Henry Pendleton")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset All Settings") {
                        resetSettings()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func resetSettings() {
        enableHaptics = true
        enableSounds = true
        showExtendedScoreIndicator = true
        autoSaveGames = true
        keepScreenOn = false
        UIApplication.shared.isIdleTimerDisabled = false
        selectedBackgroundRaw = BackgroundStyle.classic.rawValue
    }
}

struct BackgroundSelectionGrid: View {
    @Binding var selectedBackgroundRaw: String
    
    private var selectedBackground: BackgroundStyle {
        BackgroundStyle(rawValue: selectedBackgroundRaw) ?? .classic
    }
    
    let columns = [GridItem(.adaptive(minimum: 80))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(BackgroundStyle.allCases) { style in
                BackgroundOptionView(
                    style: style,
                    isSelected: selectedBackground == style,
                    action: { selectedBackgroundRaw = style.rawValue }
                )
            }
        }
    }
}

struct BackgroundOptionView: View {
    let style: BackgroundStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            style.previewThumbnail
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
                .onTapGesture(perform: action)
            
            Text(style.displayName)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}

#Preview {
    SettingsView()
}