import SwiftUI

struct CircularScoreProgressView: View {
    let player1Score: Int
    let player2Score: Int
    let player1Name: String
    let player2Name: String
    let player1Color: Color
    let player2Color: Color
    let maxScore: Int = 121
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background track - outer perimeter
                PerimeterPath()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .padding(4)
                
                // Player 1 progress (outer track - blue)
                PerimeterPath()
                    .trim(from: 0, to: min(1.0, Double(player1Score) / Double(maxScore)))
                    .stroke(player1Color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .padding(4)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: player1Score)
                
                // Background track - inner perimeter
                PerimeterPath()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    .padding(16)
                
                // Player 2 progress (inner track - orange)
                PerimeterPath()
                    .trim(from: 0, to: min(1.0, Double(player2Score) / Double(maxScore)))
                    .stroke(player2Color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .padding(16)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: player2Score)
            }
        }
    }
}

struct PerimeterPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Match iOS device corner radius - varies by device size
        let cornerRadius: CGFloat = {
            let screenWidth = rect.width
            if screenWidth <= 375 { // iPhone SE, iPhone 12/13/14 mini
                return 39.0
            } else if screenWidth <= 393 { // iPhone 12/13/14/15 Pro
                return 47.0
            } else if screenWidth <= 430 { // iPhone 12/13/14/15 Pro Max, iPhone 15/16 Plus
                return 55.0
            } else { // Larger devices like iPad
                return 18.0
            }
        }()
        
        let width = rect.width
        let height = rect.height
        
        // Start at top-left corner, move clockwise around perimeter
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Top-right corner
        path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(-90),
                   endAngle: .degrees(0),
                   clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        
        // Bottom-right corner
        path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(0),
                   endAngle: .degrees(90),
                   clockwise: false)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        
        // Bottom-left corner
        path.addArc(center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(90),
                   endAngle: .degrees(180),
                   clockwise: false)
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top-left corner
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: .degrees(180),
                   endAngle: .degrees(270),
                   clockwise: false)
        
        return path
    }
}

#Preview {
    CircularScoreProgressView(
        player1Score: 45,
        player2Score: 78,
        player1Name: "Player 1",
        player2Name: "Player 2",
        player1Color: .blue,
        player2Color: .orange
    )
    .frame(width: 350, height: 600)
    .padding()
    .background(Color.black)
}