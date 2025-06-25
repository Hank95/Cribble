import SwiftUI

enum BackgroundStyle: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case feltGreen = "Felt Green"
    case midnightBlue = "Midnight Blue"
    case warmGradient = "Warm Sunset"
    case coolGradient = "Ocean Breeze"
    case subtlePattern = "Subtle Pattern"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    // Return appropriate text color for this background
    var titleTextColor: Color {
        switch self {
        case .classic:
            return .primary
        case .feltGreen:
            return .white
        case .midnightBlue:
            return .white
        case .warmGradient:
            return .black
        case .coolGradient:
            return .black
        case .subtlePattern:
            return .primary
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        switch self {
        case .classic:
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
        case .feltGreen:
            ZStack {
                Color(red: 0.18, green: 0.35, blue: 0.25)
                    .ignoresSafeArea()
                
                // Add subtle texture overlay
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                    .overlay(
                        GeometryReader { geometry in
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let spacing: CGFloat = 2
                                
                                for x in stride(from: 0, to: width, by: spacing) {
                                    for y in stride(from: 0, to: height, by: spacing) {
                                        if Int.random(in: 0...3) == 0 {
                                            path.addEllipse(in: CGRect(x: x, y: y, width: 0.5, height: 0.5))
                                        }
                                    }
                                }
                            }
                            .fill(Color.black.opacity(0.03))
                        }
                    )
            }
            
        case .midnightBlue:
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.1, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Subtle stars effect
                GeometryReader { geometry in
                    ForEach(0..<30, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                    }
                }
                .ignoresSafeArea()
            }
            
        case .warmGradient:
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.85, blue: 0.75),
                    Color(red: 0.85, green: 0.65, blue: 0.55),
                    Color(red: 0.75, green: 0.55, blue: 0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(0.8)
            .background(Color(UIColor.systemBackground))
            
        case .coolGradient:
            LinearGradient(
                colors: [
                    Color(red: 0.65, green: 0.85, blue: 0.95),
                    Color(red: 0.45, green: 0.65, blue: 0.85),
                    Color(red: 0.55, green: 0.75, blue: 0.95)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            .opacity(0.7)
            .background(Color(UIColor.systemBackground))
            
        case .subtlePattern:
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    Path { path in
                        let size: CGFloat = 30
                        let rows = Int(geometry.size.height / size) + 1
                        let columns = Int(geometry.size.width / size) + 1
                        
                        for row in 0..<rows {
                            for column in 0..<columns {
                                let x = CGFloat(column) * size
                                let y = CGFloat(row) * size
                                
                                // Create diagonal lines pattern
                                if (row + column) % 2 == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                    path.addLine(to: CGPoint(x: x + size, y: y + size))
                                }
                            }
                        }
                    }
                    .stroke(Color(UIColor.tertiaryLabel).opacity(0.1), lineWidth: 1)
                }
                .ignoresSafeArea()
            }
        }
    }
    
    // Preview thumbnail for settings
    @ViewBuilder
    var previewThumbnail: some View {
        self.backgroundView
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
    }
}

// View modifier to apply background
struct AppBackgroundModifier: ViewModifier {
    let style: BackgroundStyle
    
    func body(content: Content) -> some View {
        ZStack {
            style.backgroundView
            content
        }
    }
}

extension View {
    func appBackground(_ style: BackgroundStyle) -> some View {
        modifier(AppBackgroundModifier(style: style))
    }
    
    func transparentNavigationBar() -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .tabBar)
    }
}

// Custom UIViewControllerRepresentable to force transparent background
struct TransparentBackground: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.view.backgroundColor = .clear
    }
}