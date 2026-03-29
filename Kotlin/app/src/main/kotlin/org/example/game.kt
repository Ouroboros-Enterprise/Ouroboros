package org.example

import java.util.Scanner

class Game(start_x: Int, start_y: Int) {
    private var score: Int = 0
    private var snake: Snake
    private var apple: Apple
    private var gui: GUI = GUI()

    init {
        snake = Snake(start_x, start_y, Node(start_x, start_y + 1, null))
        apple = Apple(snake)
    }

    public fun start() {
        Terminal.hideCursor()

        var dx = 1
        var dy = 0
        var running = true

        while (true) {
            val input = Input.getKeyPress()

            if (input != null) {
                when (input) {
                    "w", "W", "\u001b[A" -> {
                        if (dy != 1) {
                            dx = 0
                            dy = -1
                        }
                    }
                    "s", "S", "\u001b[B" -> {
                        if (dy != -1) {
                            dx = 0
                            dy = 1
                        }
                    }
                    "a", "A", "\u001b[D" -> {
                        if (dx != 1) {
                            dx = -1
                            dy = 0
                        }
                    }
                    "d", "D", "\u001b[C" -> {
                        if (dx != -1) {
                            dx = 1
                            dy = 0
                        }
                    }
                    "q", "Q" -> running = false
                }
            }
        
            if (!running) {
                break
            }

            val ax = snake.head.x + dx
            val ay = snake.head.y + dy

            val grow = ax == apple.x && ay == apple.y

            if (grow){
                apple.eat(snake)
                ++score
            }

            if (!snake.move(ax, ay, grow)) {
                break
            }

            gui.genGui(snake, apple, score)

            Thread.sleep(300)
        }
        gui.gameOver()
        Terminal.showCursor()
        Input.waitForExit()
    }
}