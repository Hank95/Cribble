import SwiftUI

struct ScoreDialView: View {
    @Binding var selectedScore: Int
    @State private var rotationAngle: Double = 0
    @State private var isDragging: Bool = false
    @State private var lastHapticValue: Int = 0
    @State private var isAddMode: Bool = true // true = add mode, false = subtract mode
    @EnvironmentObject var userSettings: UserSettings

    private let maxScore = 29
    private let degreesPerValue: Double = 360.0 / 29.0 // 360 degrees for 29 points

    /// Calculate dial radius based on available size
    private func dialRadius(for size: CGFloat) -> CGFloat {
        // The dial needs room for the pointer (which extends beyond the circle)
        // So the actual circle radius should be smaller than half the container
        // Pointer is about 10% of the radius, so use 45% of container size
        return size * 0.45
    }

    /// Calculate pointer size based on dial radius
    private func pointerSize(for radius: CGFloat) -> CGFloat {
        return max(radius * 0.12, 10) // At least 10pt, scales with dial
    }

    /// Calculate font size based on dial radius
    private func centerFontSize(for radius: CGFloat) -> CGFloat {
        return max(radius * 0.45, 18) // Scales with dial, minimum 18pt
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = dialRadius(for: size)
            let pointerDiameter = pointerSize(for: radius)
            let fontSize = centerFontSize(for: radius)

            ZStack {
                // Background circle
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: radius * 2, height: radius * 2)

                // Outer ring with color based on selected value
                Circle()
                    .stroke(ringColor, lineWidth: max(radius * 0.025, 2))
                    .frame(width: radius * 2, height: radius * 2)

                // Tick marks around the dial (0 to 29)
                ForEach(0...maxScore, id: \.self) { value in
                    let angle = Double(value) * degreesPerValue

                    Rectangle()
                        .fill(tickColor(for: value))
                        .frame(width: max(radius * 0.015, 1.5), height: tickHeight(for: value, radius: radius))
                        .offset(y: -radius + tickHeight(for: value, radius: radius) / 2)
                        .rotationEffect(.degrees(angle))
                }

                // Center content
                VStack(spacing: 2) {
                    Text(displayText)
                        .font(.system(size: fontSize, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .contentTransition(.numericText())

                    Text(actionText)
                        .font(.system(size: max(fontSize * 0.35, 10)))
                        .fontWeight(.medium)
                        .foregroundColor(textColor.opacity(0.7))
                }

                // Pointer indicator
                Circle()
                    .fill(pointerColor)
                    .frame(width: pointerDiameter, height: pointerDiameter)
                    .offset(y: -radius - pointerDiameter / 2)
                    .rotationEffect(.degrees(rotationAngle))

                // Invisible interaction area
                Circle()
                    .fill(Color.clear)
                    .frame(width: size, height: size)
                    .contentShape(Circle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                handleDragChanged(value, radius: radius)
                            }
                            .onEnded { _ in
                                handleDragEnded()
                            }
                    )
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            updateRotationForScore()
        }
        .onChange(of: selectedScore) { _, _ in
            updateRotationForScore()
        }
    }
    
    // MARK: - Computed Properties
    
    private var displayText: String {
        if selectedScore == 0 {
            return "0"
        } else if selectedScore > 0 {
            return "+\(selectedScore)"
        } else {
            return "\(selectedScore)"
        }
    }
    
    private var textColor: Color {
        switch selectedScore {
        case ..<0: return .red
        case 0: return .gray
        default: return .blue
        }
    }
    
    private var ringColor: Color {
        switch selectedScore {
        case ..<0: return .red
        case 0: return .gray
        default: return .blue
        }
    }
    
    private var pointerColor: Color {
        switch selectedScore {
        case ..<0: return .red
        case 0: return .gray
        default: return .blue
        }
    }
    
    private var actionText: String {
        switch selectedScore {
        case ..<0: return "Subtract"
        case 0: return "Turn dial"
        default: return "Add"
        }
    }
    
    // MARK: - Helper Functions
    
    private func tickColor(for value: Int) -> Color {
        let absScore = abs(selectedScore)
        let highlightedTick: Int
        
        if selectedScore == 0 {
            highlightedTick = 0
        } else if selectedScore > 0 {
            // Add mode: normal tick highlighting
            highlightedTick = absScore
        } else {
            // Subtract mode: reverse tick highlighting
            // When at -1, highlight tick 29; when at -2, highlight tick 28, etc.
            highlightedTick = maxScore + 1 - absScore
        }
        
        if value == highlightedTick {
            return selectedScore >= 0 ? .blue : .red
        } else if value == 0 {
            return .gray.opacity(0.8)
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func tickHeight(for value: Int, radius: CGFloat) -> CGFloat {
        let baseHeight = radius * 0.1
        if value == 0 {
            return baseHeight * 2 // Longer tick for zero
        } else if value % 5 == 0 {
            return baseHeight * 1.5 // Medium tick for multiples of 5
        } else {
            return baseHeight // Short tick for other values
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value, radius: CGFloat) {
        if !isDragging {
            isDragging = true
            lastHapticValue = selectedScore
        }

        // Calculate angle from center to touch point
        let center = CGPoint(x: radius, y: radius)
        let touchPoint = CGPoint(x: value.location.x, y: value.location.y)
        
        let deltaX = touchPoint.x - center.x
        let deltaY = touchPoint.y - center.y
        
        // Calculate angle with 0 degrees at top (12 o'clock)
        let angle = atan2(deltaX, -deltaY) * 180 / .pi
        let normalizedAngle = angle < 0 ? angle + 360 : angle
        
        // Convert angle to point value (0-29)
        let pointValue = Int(round(normalizedAngle / degreesPerValue))
        let clampedPoints = max(0, min(maxScore, pointValue))
        
        let newScore: Int
        if clampedPoints == 0 {
            // At zero - reset to add mode for next movement
            newScore = 0
            isAddMode = true
        } else {
            // Determine mode based on which direction we moved from zero
            if selectedScore == 0 {
                // Just moved away from zero - determine mode
                if normalizedAngle <= 180 {
                    isAddMode = true  // Clockwise = add mode
                } else {
                    isAddMode = false // Counter-clockwise = subtract mode
                }
            }
            
            if isAddMode {
                // Add mode: clockwise direction gives positive points
                newScore = clampedPoints
            } else {
                // Subtract mode: counter-clockwise direction gives negative points
                // Map the angle so first tick counter-clockwise is -1
                let subtractPoints = 30 - clampedPoints  // Reverses: 29->1, 28->2, etc.
                newScore = -subtractPoints
            }
        }
        
        if newScore != selectedScore {
            selectedScore = newScore
            
            // Set rotation angle based on mode
            if isAddMode || newScore == 0 {
                // Add mode or zero: normal clockwise rotation
                rotationAngle = Double(abs(selectedScore)) * degreesPerValue
            } else {
                // Subtract mode: counter-clockwise rotation (negative angle)
                rotationAngle = 360.0 - (Double(abs(selectedScore)) * degreesPerValue)
            }
            
            // Haptic feedback on value change
            if abs(newScore - lastHapticValue) >= 1 {
                if userSettings.enableHaptics {
                    triggerHapticFeedback()
                }
                lastHapticValue = newScore
            }
        }
    }
    
    private func handleDragEnded() {
        isDragging = false
        snapToNearestValue()
        if userSettings.enableHaptics {
            triggerHapticFeedback(style: .medium)
        }
    }
    
    private func updateRotationForScore() {
        if !isDragging {
            let absoluteValue = abs(selectedScore)
            let targetAngle: Double
            
            if selectedScore >= 0 {
                // Add mode or zero: normal clockwise rotation
                targetAngle = Double(absoluteValue) * degreesPerValue
            } else {
                // Subtract mode: counter-clockwise rotation
                targetAngle = 360.0 - (Double(absoluteValue) * degreesPerValue)
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                rotationAngle = targetAngle
            }
        }
    }
    
    private func snapToNearestValue() {
        updateRotationForScore()
    }
    
    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
}


#Preview {
    VStack(spacing: 40) {
        Text("Rotational Score Dial")
            .font(.title)
        
        ScoreDialView(selectedScore: .constant(0))
            .frame(width: 200, height: 200)
    }
    .padding()
}