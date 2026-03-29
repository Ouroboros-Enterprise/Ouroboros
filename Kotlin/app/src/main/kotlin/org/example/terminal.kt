package org.example

object Terminal {
    fun gotoXY(x: Int, y: Int) {
        System.out.print("\u001B[" + y + ";" + x + "H")
    }

    fun hideCursor() {
        System.out.print("\u001B[?25l")
    }

    fun showCursor() {
        System.out.print("\u001B[?25h")
    }

    fun clearDisplay() {
        System.out.print("\u001B[2J\u001B[H")
    }
}