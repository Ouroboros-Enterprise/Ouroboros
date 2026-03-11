package include

import "time"

func SleepMS(milliseconds int) {
	time.Sleep(time.Duration(milliseconds) * time.Millisecond)
}

func SleepS(seconds int) {
	time.Sleep(time.Duration(seconds) * time.Second)
}