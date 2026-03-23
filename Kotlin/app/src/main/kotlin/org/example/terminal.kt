package org.example

class Terminal {
    public fun gotoXY(x: Int, y: Int) {
        System.out.print("\u001B[" + y + ";" + x + "H")
    }

    public fun hideCursor() {
        System.out.print("\u001B[?25l")
    }

    public fun showCursor() {
        System.out.print("\u001B[?25h")
    }

    public fun clearDisplay() {
        System.out.print("\u001B[2J\u001B[H")
    }
}