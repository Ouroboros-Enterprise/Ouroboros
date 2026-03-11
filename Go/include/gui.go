package include

import (
	"fmt"
	"strings"
)

type GUI struct {
	grid [22][22]uint8
}

func NewGUI() *GUI {
	gui := &GUI{}

	for i := range gui.grid {
		for j := range gui.grid[i] {
			gui.grid[i][j] = ' '
		}
	}

	return gui
}

func PlaceBorders(gui *GUI) {
	for i := range gui.grid {
		gui.grid[0][i] = '#'
		gui.grid[21][i] = '#'
		gui.grid[i][0] = '#'
		gui.grid[i][21] = '#'
	}
}

func PlaceSnake(gui *GUI, snake *Snake) {
	if snake == nil || snake.Head == nil {
		return
	}

	curr := snake.Head

	gui.grid[curr.X+1][curr.Y+1] = 'X'

	curr = curr.Next

	for ; curr != nil; curr = curr.Next {
		gui.grid[curr.X+1][curr.Y+1] = 'O'
	}
}

func PlaceApple(gui *GUI, apple *Apple) {
	gui.grid[apple.X+1][apple.Y+1] = '@'
}

func GenGUI(gui *GUI, snake *Snake, apple *Apple, score int) {
	var out strings.Builder

	GotoXY(1, 1)

	for i := range gui.grid {
		for j := range gui.grid[i] {
			gui.grid[i][j] = ' '
		}
	}

	PlaceBorders(gui)
	PlaceSnake(gui, snake)
	PlaceApple(gui, apple)

	for j := range 22 {
		for i := range 22 {
			field := gui.grid[i][j]

			if field == '#' {
				out.WriteString("##")
			} else {
				out.WriteByte(field)
				out.WriteByte(' ')
			}
		}

		if j == 0 {
			out.WriteString(fmt.Sprintf("  Score:  %d", score))
		}
		out.WriteByte('\n')
	}
	fmt.Print(out.String())
}

func GameOver() {
	GotoXY(1, 23)

	fmt.Println("         ___                 ")
    fmt.Println("        / __|__ _ _ __  ___  ")
    fmt.Println("       | (_ / _` | ''  \\/ -_) ")
    fmt.Println("        \\___\\__,_|_|_|_\\___| ")
    fmt.Println("         ___                 ")
    fmt.Println("        / _ \\_ _____ _ _     ")
    fmt.Println("       | (_) \\ V / -_) ''_|   ")
    fmt.Println("        \\___/ \\_/\\___|_|     ")
}
