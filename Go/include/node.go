package include

type Node struct {
	X, Y int
	Next *Node
}

func NewNode(x, y int, next *Node) *Node {
	return &Node{x, y, next}
}
