import SwiftUI

struct ScoreDialView: View {
    @Binding var selectedScore: Int
    @State private var rotationAngle: Double = 0
    @State private var isDragging: Bool = false
    @State private var lastHapticValue: Int = 0
    @State private var isAddMode: Bool = true // true = add mode, false = subtract mode
    
    private let maxScore = 29
    private let dialRadius: CGFloat = 80
    private let degreesPerValue: Double = 360.0 / 29.0 // 360 degrees for 29 points
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: dialRadius * 2, height: dialRadius * 2)
            
            // Outer ring with color based on selected value
            Circle()
                .stroke(ringColor, lineWidth: 4)
                .frame(width: dialRadius * 2, height: dialRadius * 2)
            
            // Tick marks around the dial (0 to 29)
            ForEach(0...maxScore, id: \.self) { value in
                let angle = Double(value) * degreesPerValue
                
                Rectangle()
                    .fill(tickColor(for: value))
                    .frame(width: 2, height: tickHeight(for: value))
                    .offset(y: -dialRadius + tickHeight(for: value) / 2)
                    .rotationEffect(.degrees(angle))
            }
            
            // Center content
            VStack(spacing: 4) {
                Text(displayText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .contentTransition(.numericText())
                
                Text(actionText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(textColor.opacity(0.7))
            }
            
            // Pointer indicator
            Circle()
                .fill(pointerColor)
                .frame(width: 16, height: 16)
                .offset(y: -dialRadius - 8)
                .rotationEffect(.degrees(rotationAngle))
            
            // Invisible interaction area
            Circle()
                .fill(Color.clear)
                .frame(width: dialRadius * 2.5, height: dialRadius * 2.5)
                .contentShape(Circle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { _ in
                            handleDragEnded()
                        }
                )
        }
        .onAppear {
            updateRotationForScore()
        }
        .onChange(of: selectedScore) {
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
    
    private func tickHeight(for value: Int) -> CGFloat {
        if value == 0 {
            return 16 // Longer tick for zero
        } else if value % 5 == 0 {
            return 12 // Medium tick for multiples of 5
        } else {
            return 8 // Short tick for other values
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        if !isDragging {
            isDragging = true
            lastHapticValue = selectedScore
        }
        
        // Calculate angle from center to touch point
        let center = CGPoint(x: dialRadius, y: dialRadius)
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
                triggerHapticFeedback()
                lastHapticValue = newScore
            }
        }
    }
    
    private func handleDragEnded() {
        isDragging = false
        snapToNearestValue()
        triggerHapticFeedback(style: .medium)
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