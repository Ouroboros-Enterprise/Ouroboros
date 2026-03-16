package com.ouroboros.include;

import java.util.Arrays;

public class GUI {
    private final char[][] map;

    public GUI() {
        map = new char[22][22];
        for (char[] row : map) {
            Arrays.fill(row, ' ');
        }
    }

    public void genGUI(Snake snake, Apple apple, int score) {
        Terminal.gotoXY(1, 1);

        for (char[] row : map) {
            Arrays.fill(row, ' ');
        }

        placeBorders();
        placeSnake(snake);
        placeApple(apple);

        StringBuilder out = new StringBuilder(1000);

        for (int j = 0; j < 22; ++j) {
            for (int i = 0; i < 22; ++i) {
                char field = map[i][j];

                if (field == '#') {
                    out.append("##");
                } else {
                    out.append(field).append(' ');
                }
            }

            if (j == 0) {
                out.append("  Score:  ").append(score);
            }

            out.append("\n");
        }

        System.out.print(out.toString());
    }

    public static void gameOver() {
        Terminal.gotoXY(1, 23);

        System.out.println("         ___                 ");
        System.out.println("        / __|__ _ _ __  ___  ");
        System.out.println("       | (_ / _` | ''  \\/ -_) ");
        System.out.println("        \\___\\__,_|_|_|_\\___| ");
        System.out.println("         ___                 ");
        System.out.println("        / _ \\_ _____ _ _     ");
        System.out.println("       | (_) \\ V / -_) ''_|   ");
        System.out.println("        \\___/ \\_/\\___|_|     ");
    }

    private void placeBorders() {
        for (int i = 0; i < 22; ++i) {
            map[0][i] = '#';
            map[21][i] = '#';
            map[i][0] = '#';
            map[i][21] = '#';
        }
    }

    private void placeSnake(Snake snake) {
        for (Node node : snake.head) {
            if (node == snake.head) {
                map[node.x + 1][node.y + 1] = 'X';
            } else {
                map[node.x + 1][node.y + 1] = 'O';
            }
        }
    }

    private void placeApple(Apple apple) {
        map[apple.x + 1][apple.y + 1] = '@';
    }
}
