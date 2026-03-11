package include

type Game struct {
	AppleCount int
	Snake      *Snake
	Apple      *Apple
	GUI        *GUI
}

func NewGame(startX, startY int) *Game {
	snake := NewSnake(startX, startY, NewNode(startX, startY+1, nil))
	apple := NewApple(snake)
	gui := NewGUI()
	return &Game{0, snake, apple, gui}
}

func Start(game *Game) {
	HideCursor()

	snake := game.Snake
	apple := game.Apple
	gui := game.GUI

	dx, dy := 1, 0
	running := true

	for {
		input := uint8(GetKey())

		switch input {
		case 'w', 'W', 72:
			if dy != 1 {
				dx, dy = 0, -1
			}
		case 's', 'S', 80:
			if dy != -1 {
				dx, dy = 0, 1
			}
		case 'a', 'A', 75:
			if dx != 1 {
				dx, dy = -1, 0
			}
		case 'd', 'D', 77:
			if dx != -1 {
				dx, dy = 1, 0
			}
		case 'q', 'Q', 27:
			running = false
		}

		if !running {
			break
		}

		ax := snake.Head.X + dx
		ay := snake.Head.Y + dy

		grow := (ax == apple.X && ay == apple.Y)

		if grow {
			Eat(apple, snake)
			game.AppleCount++
		}

		if !MoveSnake(snake, ax, ay, grow) {
			break
		}

		GenGUI(gui, snake, apple, game.AppleCount)

		SleepMS(300)
	}
	GameOver()
	ShowCursor()
	WaitForExit()
}