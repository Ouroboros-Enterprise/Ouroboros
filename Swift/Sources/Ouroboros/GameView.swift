import SwiftUI

struct GameView: View {
    @ObservedObject var engine: GameEngine
    @FocusState private var isFocused: Bool
    
    // Aesthetic constants
    let cellSize: CGFloat = 25
    let gridPadding: CGFloat = 2
    
    var body: some View {
        ZStack {
            // Background Liquid Glass Effect
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header / Score
                HStack {
                    Text("OUROBOROS")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                    
                    Spacer()
                    
                    Text("SCORE: \(engine.score)")
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Game Board
                ZStack {
                    // Board Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Grid and Entities
                    Grid(horizontalSpacing: gridPadding, verticalSpacing: gridPadding) {
                        ForEach(0..<engine.gridHeight, id: \.self) { y in
                            GridRow {
                                ForEach(0..<engine.gridWidth, id: \.self) { x in
                                    cellView(x: x, y: y)
                                }
                            }
                        }
                    }
                    .padding(16)
                    
                    // Overlays
                    if engine.isGameOver {
                        overlayText("GAME OVER\nPress R to Retry")
                    } else if !engine.isRunning {
                        overlayText("Press WASD / Arrows to Start")
                    }
                }
                .fixedSize()
                .padding(.bottom, 20)
            }
        }
        .focusable()
        .focused($isFocused)
        .onAppear {
            isFocused = true
            engine.resetGame(start: false)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let pos = Position(x: x, y: y)
        let isSnake = engine.snake.contains(pos)
        let isHead = engine.snake.first == pos
        let isApple = engine.apple == pos
        
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.1))
                .frame(width: cellSize, height: cellSize)
            
            if isApple {
                // Apple Styling
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.red, .red.opacity(0.6)],
                            center: .center,
                            startRadius: 2,
                            endRadius: cellSize/2
                        )
                    )
                    .frame(width: cellSize * 0.8, height: cellSize * 0.8)
                    .shadow(color: .red, radius: 4)
            } else if isSnake {
                // Snake Styling
                RoundedRectangle(cornerRadius: isHead ? 6 : 4)
                    .fill(
                        LinearGradient(
                            colors: isHead ? [.cyan, .blue] : [.blue.opacity(0.8), .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: cellSize * 0.9, height: cellSize * 0.9)
                    .shadow(color: .cyan.opacity(0.5), radius: isHead ? 4 : 2)
            }
        }
    }
    
    @ViewBuilder
    private func overlayText(_ text: String) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .cornerRadius(16)
            
            Text(text)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}
