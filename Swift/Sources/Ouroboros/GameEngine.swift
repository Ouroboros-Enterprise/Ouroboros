import SwiftUI
import Combine
#if os(macOS)
import AppKit
#endif

struct Position: Equatable, Hashable {
    var x: Int
    var y: Int
}

enum Direction {
    case up, down, left, right
}

class GameEngine: ObservableObject {
    @Published var snake: [Position] = []
    @Published var apple: Position = Position(x: 0, y: 0)
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isRunning: Bool = false
    
    let gridWidth = 20
    let gridHeight = 20
    
    private var currentDirection: Direction = .up
    private var nextDirection: Direction = .up
    
    private var timer: AnyCancellable?
    private let initialTickRate: TimeInterval = 0.25
    private var currentTickRate: TimeInterval = 0.25
    
    #if os(macOS)
    private var eventMonitor: Any?
    #endif
    
    init() {
        print("DEBUG [GameEngine]: init() called.")
        resetGame(start: false)
        setupKeyboardMonitor()
    }
    
    deinit {
        #if os(macOS)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        #endif
    }
    
    private func setupKeyboardMonitor() {
        print("DEBUG [GameEngine]: setupKeyboardMonitor() registering NSEvent monitor.")
        #if os(macOS)
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
        #endif
    }
    
    func resetGame(start: Bool = true) {
        print("DEBUG [GameEngine]: resetGame(start: \(start)) called.")
        timer?.cancel()
        
        let startX = Int.random(in: 5..<15)
        let startY = Int.random(in: 5..<15)
        
        // Starts with head and one tail segment
        snake = [
            Position(x: startX, y: startY),
            Position(x: startX, y: startY + 1)
        ]
        
        currentDirection = .up
        nextDirection = .up
        
        score = 0
        isGameOver = false
        currentTickRate = initialTickRate
        spawnApple()
        
        if start {
            startGame()
        }
    }
    
    func startGame() {
        print("DEBUG [GameEngine]: startGame() called. isRunning=\(isRunning) isGameOver=\(isGameOver)")
        guard !isRunning && !isGameOver else { return }
        isRunning = true
        scheduleTimer()
    }
    
    func pauseGame() {
        print("DEBUG [GameEngine]: pauseGame() called.")
        isRunning = false
        timer?.cancel()
    }
    
    private func scheduleTimer() {
        timer?.cancel()
        timer = Timer.publish(every: currentTickRate, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameTick()
            }
    }
    
    #if os(macOS)
    private func handleKeyEvent(_ event: NSEvent) {
        let chars = event.charactersIgnoringModifiers?.lowercased() ?? ""
        let keyCode = event.keyCode
        
        print("DEBUG [GameEngine]: handleKeyEvent() received keyCode: \(keyCode) chars: '\(chars)' represents: \(event.characters ?? "nil")")
        
        if isGameOver {
            if chars == "r" || keyCode == 15 {
                resetGame()
            }
            return
        }
        
        var handled = false
        
        // 126=up, 125=down, 123=left, 124=right
        if chars == "w" || keyCode == 126 {
            if currentDirection != .down { nextDirection = .up }
            handled = true
        } else if chars == "s" || keyCode == 125 {
            if currentDirection != .up { nextDirection = .down }
            handled = true
        } else if chars == "a" || keyCode == 123 {
            if currentDirection != .right { nextDirection = .left }
            handled = true
        } else if chars == "d" || keyCode == 124 {
            if currentDirection != .left { nextDirection = .right }
            handled = true
        }
        
        if handled && !isRunning {
            startGame()
        }
    }
    #endif
    
    private func gameTick() {
        guard isRunning, !isGameOver, let head = snake.first else { return }
        
        currentDirection = nextDirection
        var nextHead = head
        
        switch currentDirection {
        case .up: nextHead.y -= 1
        case .down: nextHead.y += 1
        case .left: nextHead.x -= 1
        case .right: nextHead.x += 1
        }
        
        // Wall collision
        if nextHead.x < 0 || nextHead.x >= gridWidth || nextHead.y < 0 || nextHead.y >= gridHeight {
            triggerGameOver()
            return
        }
        
        // Self collision
        // We drop the last element for collision check because it will move forward, unless we eat an apple
        let bodyToCheck = snake.dropLast()
        if bodyToCheck.contains(nextHead) {
            triggerGameOver()
            return
        }
        
        snake.insert(nextHead, at: 0)
        
        if nextHead == apple {
            print("DEBUG [GameEngine]: Apple eaten at (\(nextHead.x), \(nextHead.y))! Score increasing.")
            score += 1
            adjustSpeed()
            spawnApple()
        } else {
            snake.removeLast()
        }
    }
    
    private func triggerGameOver() {
        print("DEBUG [GameEngine]: triggerGameOver() called! Score: \(score)")
        isGameOver = true
        isRunning = false
        timer?.cancel()
    }
    
    private func spawnApple() {
        var newPosition: Position
        repeat {
            newPosition = Position(x: Int.random(in: 0..<gridWidth), y: Int.random(in: 0..<gridHeight))
        } while snake.contains(newPosition)
        
        apple = newPosition
    }
    
    private func adjustSpeed() {
        let maxSpeed: TimeInterval = 0.08
        // Speed up slightly every 5 apples
        if score > 0 && score % 5 == 0 && currentTickRate > maxSpeed {
            currentTickRate -= 0.02
            scheduleTimer()
        }
    }
}
