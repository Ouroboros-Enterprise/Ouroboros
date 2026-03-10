from node import Node


class Snake(Node):
    def __init__(self, x: int, y: int, next: Node | None) -> None:
        super().__init__(x, y, next)

    def move(self, x: int, y: int, grow: bool) -> bool:
        old_head: Node = Node(self.x, self.y, self.next)
        self.next = old_head

        self.x = x
        self.y = y

        if not grow and self.next is not None:
            if self.next.next is None:
                self.next = None
            else:
                curr: Node = self.next

                while curr.next is not None and curr.next.next is not None:
                    curr = curr.next

                curr.next = None

        return not self._self_collision() and not self._wall_collision()

    def _wall_collision(self) -> bool:
        return self.x < 0 or self.x >= 20 or self.y < 0 or self.y >= 20

    def _self_collision(self) -> bool:
        curr: Node | None = self.next

        while curr is not None:
            if curr.x == self.x and curr.y == self.y:
                return True
            curr = curr.next

        return False
