from snake import Snake
from random import randint
from node import Node


class Apple:
    def __init__(self, snake: Snake) -> None:
        self.x: int
        self.y: int

        self.eat(snake)

    def eat(self, snake: Snake) -> None:
        for i in range(1000):
            blocked: bool = False

            x: int = randint(0, 19)
            y: int = randint(0, 19)

            curr: Node | None = snake

            while curr is not None:
                if curr.x == x and curr.y == y:
                    blocked = True
                    break
                curr = curr.next

            if not blocked:
                self.x = x
                self.y = y
                break
