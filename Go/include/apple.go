package include

type Apple struct {
	X, Y int
}

func NewApple(snake *Snake) *Apple {
	apple := &Apple{0, 0}
	Eat(apple, snake)
	return apple
}

func Eat(apple *Apple, snake *Snake) {
	for range 1000 {
		blocked := false

		x, y := GetRandInt(0, 19), GetRandInt(0, 19)

		for curr := snake.Head; curr != nil; curr = curr.Next {
			if curr.X == x && curr.Y == y {
				blocked = true
				break
			}
		}

		if !blocked {
			apple.X = x
			apple.Y = y
			break
		}
	}
}