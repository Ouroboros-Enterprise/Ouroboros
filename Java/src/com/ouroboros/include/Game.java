package com.ouroboros.include;

import java.util.concurrent.TimeUnit;

public class Game {
    private int score;
    private final Snake snake;
    private final Apple apple;
    private final GUI gui;

    public Game(int start_x, int start_y) {
        score = 0;
        snake = new Snake(start_x, start_y, new Node(start_x, start_y + 1, null));
        apple = new Apple(snake);
        gui = new GUI();
    }

    public void start() {
        Terminal.hideCursor();

        int dx = 1;
        int dy = 0;
        boolean running = true;

        while (true) {
            String input = Input.getKeyPress();

            if (input != null) {
                switch (input) {
                    case "w", "W", "\033[A" -> {
                        if (dy != 1) {
                            dx = 0;
                            dy = -1;
                        }
                    }
                    case "s", "S", "\033[B" -> {
                        if (dy != -1) {
                            dx = 0;
                            dy = 1;
                        }
                    }
                    case "a", "A", "\033[D" -> {
                        if (dx != 1) {
                            dx = -1;
                            dy = 0;
                        }
                    }
                    case "d", "D", "\033[C" -> {
                        if (dx != -1) {
                            dx = 1;
                            dy = 0;
                        }
                    }
                    case "q", "Q" -> running = false;
                }
            }

            if (!running)
                break;

            int ax = snake.head.x + dx;
            int ay = snake.head.y + dy;

            boolean grow = ax == apple.x && ay == apple.y;

            if (grow) {
                apple.eat(snake);
                ++score;
            }

            if (!snake.move(ax, ay, grow))
                break;

            gui.genGUI(snake, apple, score);

            try {
                TimeUnit.MILLISECONDS.sleep(300);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        GUI.gameOver();
        Terminal.showCursor();
        Input.waitForExit();
    }
}
