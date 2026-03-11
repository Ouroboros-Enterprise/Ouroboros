package include

type Snake struct {
	Head *Node
}

func NewSnake(x, y int, next *Node) *Snake {
	return &Snake{NewNode(x, y, next)}
}

func WallCollion(snake *Snake) bool {
	x := snake.Head.X
	y := snake.Head.Y
	return x < 0 || x >= 20 || y < 0 || y >= 20
}

func SelfCollision(snake *Snake) bool {
	x, y := snake.Head.X, snake.Head.Y

	for curr := snake.Head.Next; curr != nil; curr = curr.Next {
		if curr.X == x && curr.Y == y {
			return true
		}
	}
	return false
}

func MoveSnake(snake *Snake, nx, ny int, grow bool) bool {
	head := snake.Head

	oldHead := NewNode(head.X, head.Y, head.Next)

	head.Next = oldHead

	head.X = nx
	head.Y = ny

	if !grow && head.Next != nil {
		if head.Next.Next == nil {
			head.Next = nil
		} else {
			curr := snake.Head.Next
			for curr.Next != nil && curr.Next.Next != nil {
				curr = curr.Next
			}
			curr.Next = nil
		}
	}

	return !WallCollion(snake) && !SelfCollision(snake)
}