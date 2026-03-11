package main

import (
	"Ouroboros/include"
	"fmt"
	"os"
)

func main() {
	playAgain := true

	start := map[uint8]bool{
		' ': true,
		13: true,
	}

	quit := map[uint8]bool{
		'q': true,
		'Q': true,
		27: true,
	}
	retry := map[uint8]bool{
		'r': true,
		'R': true,
	}

	for playAgain {
		include.ClearDisplay()
		fmt.Println("--- OUROBOROS Go ---")
		fmt.Println("Press SPACE to start or 'Q' to Quit...")

		for {
			input := uint8(include.GetKey())

			if start[input] {
				break
			}
			
			if quit[input] {
				playAgain = false
				break
			}

			include.SleepMS(10)
		}

		if !playAgain {
			break
		}

		start_x := include.GetRandInt(0, 19)
		start_y := include.GetRandInt(0, 19)

		game := include.NewGame(start_x, start_y)

		include.Start(game)

		fmt.Printf("\n\nPress 'R' to Retry or 'Q' to Quit...")

		for {
			input := uint8(include.GetKey())

			if retry[input] {
				playAgain = true
				break
			}

			if quit[input] {
				playAgain = false
				break
			}

			include.SleepMS(10)
		}
	}

	include.HideCursor()

	fmt.Println("\nThanks for playing!")
	fmt.Println()

	for i := 5; i >= 0; i-- {
		fmt.Printf("\rClosing in %d seconds...", i)
		os.Stdout.Sync()
		include.SleepS(1)
	}

	include.ShowCursor()
	fmt.Println()
}