import SwiftUI

struct SettingsView: View {
    @StateObject private var userSettings: UserSettings
    @State private var selectedBackgroundStyle: BackgroundStyle
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        let settings = PersistenceController.shared.getUserSettings()
        _userSettings = StateObject(wrappedValue: settings)
        _selectedBackgroundStyle = State(initialValue: BackgroundStyle(rawValue: settings.selectedBackground ?? BackgroundStyle.classic.rawValue) ?? .classic)
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Options")) {
                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { userSettings.enableHaptics },
                        set: { newValue in
                            userSettings.enableHaptics = newValue
                            userSettings.save()
                        }
                    ))
                    Toggle("Sound Effects", isOn: Binding(
                        get: { userSettings.enableSounds },
                        set: { newValue in
                            userSettings.enableSounds = newValue
                            userSettings.save()
                        }
                    ))
                    Toggle("Show Extended Score Indicator", isOn: Binding(
                        get: { userSettings.showExtendedScoreIndicator },
                        set: { newValue in
                            userSettings.showExtendedScoreIndicator = newValue
                            userSettings.save()
                        }
                    ))
                    Toggle("Auto-Save Completed Games", isOn: Binding(
                        get: { userSettings.autoSaveGames },
                        set: { newValue in
                            userSettings.autoSaveGames = newValue
                            userSettings.save()
                        }
                    ))
                }
                
                Section(header: Text("Display")) {
                    Toggle("Keep Screen On", isOn: Binding(
                        get: { userSettings.keepScreenOn },
                        set: { newValue in
                            userSettings.keepScreenOn = newValue
                            userSettings.save()
                            UIApplication.shared.isIdleTimerDisabled = newValue
                        }
                    ))
                }
                
                Section(header: Text("Background Theme")) {
                    BackgroundSelectionGrid(selectedBackground: selectedBackgroundStyle) { newStyle in
                        selectedBackgroundStyle = newStyle
                        userSettings.selectedBackground = newStyle.rawValue
                        userSettings.save()
                    }
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
        userSettings.enableHaptics = true
        userSettings.enableSounds = true
        userSettings.showExtendedScoreIndicator = true
        userSettings.autoSaveGames = true
        userSettings.keepScreenOn = false
        userSettings.selectedBackground = BackgroundStyle.classic.rawValue
        selectedBackgroundStyle = .classic
        userSettings.save()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

struct BackgroundSelectionGrid: View {
    let selectedBackground: BackgroundStyle
    let onSelectionChange: (BackgroundStyle) -> Void
    
    let columns = [GridItem(.adaptive(minimum: 80))]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(BackgroundStyle.allCases) { style in
                BackgroundOptionView(
                    style: style,
                    isSelected: selectedBackground == style,
                    action: { onSelectionChange(style) }
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