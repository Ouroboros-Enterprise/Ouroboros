//go:build !windows

package include

import (
	"fmt"
	"os"
	"os/exec"
)

func getKeyPress() int {
    cbTerm := exec.Command("stty", "-F", "/dev/tty", "cbreak", "min", "0", "time", "0")
    cbTerm.Run()
    defer exec.Command("stty", "-F", "/dev/tty", "sane").Run()

    var buf [1]byte
    os.Stdin.Read(buf[:])
    if buf[0] == 0 {
        return -1
    }
    return int(buf[0])
}

func waitForExit() {
    fmt.Println("Press a key to exit...")
    
    exec.Command("stty", "-F", "/dev/tty", "cbreak", "min", "1").Run()
	defer exec.Command("stty", "-F", "/dev/tty", "sane").Run()

	var b [1]byte
	os.Stdin.Read(b[:])
}