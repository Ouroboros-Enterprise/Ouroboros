package com.ouroboros.include;

public class Terminal {
    public static void gotoXY(int x, int y) {
        System.out.printf("\033[%d;%dH", y, x);
        System.out.flush();
    }

    public static void hideCursor() {
        System.out.print("\033[?25l");
        System.out.flush();
    }

    public static void showCursor() {
        System.out.print("\033[?25h");
        System.out.flush();
    }

    public static void clearDisplay() {
        System.out.print("\033[2J\033[H");
        System.out.flush();
    }
}
