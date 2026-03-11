//go:build windows

package include

import (
	"fmt"
	"syscall"
)

var (
	msvcrt = syscall.NewLazyDLL("msvcrt.dll")
	kbhit  = msvcrt.NewProc("_kbhit")
	getch  = msvcrt.NewProc("_getch")
)

func getKeyPress() int {
	r, _, _ := kbhit.Call()
	
	if r != 0 {
		ch, _, _ := getch.Call()
		return int(ch)
	}
	return -1
}

func waitForExit() {
	fmt.Println("Press a key to exit...")

	for {
		r, _, _ := kbhit.Call()

		if r == 0 {
			break
		}
		getch.Call()
	}

	getch.Call()
}