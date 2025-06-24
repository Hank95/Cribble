import SwiftUI

struct ScoreDialView: View {
    @Binding var selectedScore: Int
    @State private var angle: Double = 0
    @State private var isDragging: Bool = false
    @State private var totalRotations: Int = 0
    @State private var lastAngle: Double = 0
    
    private let minScore = 1
    private let maxScore = 29
    private let dialMarkings = 15
    private let dialRadius: CGFloat = 100
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: dialRadius * 2, height: dialRadius * 2)
            
            Circle()
                .stroke(Color.blue, lineWidth: 4)
                .frame(width: dialRadius * 2, height: dialRadius * 2)
            
            ForEach(1...dialMarkings, id: \.self) { marking in
                let markingAngle = Double(marking - 1) * (360.0 / Double(dialMarkings))
                let radians = (markingAngle - 90) * .pi / 180
                let x = cos(radians) * dialRadius * 0.8
                let y = sin(radians) * dialRadius * 0.8
                
                Text("\(marking)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(getDialColor(for: marking))
                    .offset(x: x, y: y)
            }
            
            VStack(spacing: 4) {
                Text("\(selectedScore)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                if selectedScore > dialMarkings {
                    Text("Extended")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.7))
                }
            }
            
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .offset(x: cos((angle - 90) * .pi / 180) * dialRadius * 0.6,
                       y: sin((angle - 90) * .pi / 180) * dialRadius * 0.6)
        }
        .rotationEffect(.degrees(0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        triggerHapticFeedback()
                    }
                    
                    let vector = CGVector(dx: value.location.x - dialRadius, dy: value.location.y - dialRadius)
                    let newAngle = atan2(vector.dy, vector.dx) * 180 / .pi + 90
                    let normalizedAngle = newAngle < 0 ? newAngle + 360 : newAngle
                    
                    updateSelectedScore(for: normalizedAngle)
                }
                .onEnded { _ in
                    isDragging = false
                    snapToNearestScore()
                }
        )
        .onAppear {
            updateAngleForScore()
        }
        .onChange(of: selectedScore) { _ in
            updateAngleForScore()
        }
    }
    
    private func updateSelectedScore(for newAngle: Double) {
        angle = newAngle
        
        // Calculate the raw score based on angle (continuous)
        let anglePerScore = 360.0 / Double(dialMarkings)
        let rawDialPosition = newAngle / anglePerScore
        let currentDialScore = Int(round(rawDialPosition))
        
        // Handle the change in score
        let normalizedCurrent = currentDialScore == 0 ? dialMarkings : currentDialScore
        let previousDialScore = ((selectedScore - 1) % dialMarkings) + 1
        
        // Detect if we've crossed boundaries
        var newScore = selectedScore
        
        if isDragging {
            // Check for forward boundary crossing (15 -> 1)
            if previousDialScore >= 13 && normalizedCurrent <= 3 {
                let nextScore = selectedScore + (normalizedCurrent + dialMarkings - previousDialScore)
                if nextScore <= maxScore {
                    newScore = nextScore
                }
            }
            // Check for backward boundary crossing (1 -> 15)
            else if previousDialScore <= 3 && normalizedCurrent >= 13 {
                let nextScore = selectedScore - (previousDialScore + dialMarkings - normalizedCurrent)
                if nextScore >= minScore {
                    newScore = nextScore
                }
            }
            // Normal increment/decrement
            else {
                let diff = normalizedCurrent - previousDialScore
                let nextScore = selectedScore + diff
                if nextScore >= minScore && nextScore <= maxScore {
                    newScore = nextScore
                }
            }
            
            if newScore != selectedScore {
                selectedScore = newScore
                triggerHapticFeedback()
            }
        }
        
        lastAngle = newAngle
    }
    
    private func updateAngleForScore() {
        // Calculate which rotation we're on
        totalRotations = max(0, (selectedScore - 1) / dialMarkings)
        
        // Calculate angle within current rotation
        let positionInDial = ((selectedScore - 1) % dialMarkings) + 1
        angle = Double(positionInDial - 1) / Double(dialMarkings) * 360.0
        lastAngle = angle
    }
    
    private func snapToNearestScore() {
        // Snap to the current score position
        let currentDialPosition = ((selectedScore - 1) % dialMarkings)
        let targetAngle = Double(currentDialPosition) / Double(dialMarkings) * 360.0
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
            angle = targetAngle
            lastAngle = targetAngle
        }
    }
    
    private func getDialColor(for marking: Int) -> Color {
        let currentDialPosition = ((selectedScore - 1) % dialMarkings) + 1
        return marking == currentDialPosition ? .blue : .gray
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    ScoreDialView(selectedScore: .constant(5))
        .padding()
}