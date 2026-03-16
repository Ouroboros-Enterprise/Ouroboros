package com.ouroboros;

import java.util.HashSet;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import com.ouroboros.include.Game;
import com.ouroboros.include.Input;
import com.ouroboros.include.Terminal;

public class Main {
    private final static Random random = new Random();

    public static void main(String[] args) {
        boolean playAgain = true;

        HashSet<String> start = new HashSet<>(Set.of(" ", "\n", "\r\n", "\r"));
        HashSet<String> quit = new HashSet<>(Set.of("q", "Q", "\033"));
        HashSet<String> retry = new HashSet<>(Set.of("r", "R"));

        while (playAgain) {
            Terminal.clearDisplay();

            System.out.println("--- OUROBOROS Java ---");
            System.out.println("Press SPACE to start or 'Q' to Quit...");

            while (true) {
                String input = Input.getKeyPress();

                if (input != null) {
                    if (start.contains(input))
                        break;
                    if (quit.contains(input)) {
                        playAgain = false;
                        break;
                    }
                }

                try {
                    TimeUnit.MILLISECONDS.sleep(10);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }

            if (!playAgain)
                break;

            int sx = random.nextInt(20);
            int sy = random.nextInt(20);

            new Game(sx, sy).start();

            System.out.println("\n\nPress 'R' to Retry or 'Q' to Quit...");

            while (true) {
                String input = Input.getKeyPress();

                if (input != null) {
                    if (retry.contains(input))
                        break;
                    if (quit.contains(input)) {
                        playAgain = false;
                        break;
                    }
                }

                try {
                    TimeUnit.MILLISECONDS.sleep(10);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }

        Terminal.hideCursor();
        System.out.println("\nThanks for playing!");

        for (int i = 5; i >= 0; --i) {
            System.out.printf("\rClosing in %d seconds...", i);

            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        Terminal.showCursor();
        Input.close();
        System.exit(0);
    }
}
