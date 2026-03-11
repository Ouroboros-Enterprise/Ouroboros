package include

import (
	"fmt"
	"os"
)

func GotoXY(x, y int) {
	fmt.Printf("\033[%d;%dH", y, x)
	os.Stdout.Sync()
}

func HideCursor() {
	fmt.Printf("\033[?25l")
	os.Stdout.Sync()
}

func ShowCursor() {
	fmt.Printf("\033[?25h")
	os.Stdout.Sync()
}

func ClearDisplay() {
	fmt.Printf("\033[2J\033[H")
	os.Stdout.Sync()
}