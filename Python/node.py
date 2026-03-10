class Node:
    def __init__(self, x: int, y: int, next: Node | None) -> None:
        self.x: int = x
        self.y: int = y
        self.next: Node | None = next
