import numpy as np
from snake import Snake
from apple import Apple
from terminal import goto_xy
from node import Node
from sys import stdout


class GUI:
    def __init__(self) -> None:
        self.map = np.zeros((22, 22), dtype="int32")

    def gen_gui(self, snake: Snake, apple: Apple, score: int) -> None:
        goto_xy(1, 1)

        self.map.fill(ord(" "))

        self._place_borders()
        self._place_snake(snake)
        self._place_apple(apple)

        output = []
        for j in range(22):
            row_str = ""
            for i in range(22):
                field = self.map[i, j]

                if field == ord("#"):
                    row_str += "##"
                else:
                    row_str += f"{chr(field)} "

            if j == 0:
                row_str += f"  Score:  {score}"

            output.append(row_str)

        stdout.write("\n".join(output) + "\n")
        stdout.flush()

    def game_over(self) -> None:
        goto_xy(1, 23)

        stdout.write("         ___                 \n")
        stdout.write("        / __|__ _ _ __  ___  \n")
        stdout.write("       | (_ / _` | ''  \\/ -_) \n")
        stdout.write("        \\___\\__,_|_|_|_\\___| \n")
        stdout.write("         ___                 \n")
        stdout.write("        / _ \\_ _____ _ _     \n")
        stdout.write("       | (_) \\ V / -_) ''_|   \n")
        stdout.write("        \\___/ \\_/\\___|_|     \n")

    def _place_borders(self) -> None:
        self.map[0, :] = ord("#")
        self.map[21, :] = ord("#")
        self.map[:, 0] = ord("#")
        self.map[:, 21] = ord("#")

    def _place_snake(self, snake: Snake) -> None:
        if not snake:
            return

        curr: Node | None = snake

        self.map[curr.x + 1, curr.y + 1] = ord("X")
        curr = curr.next

        while curr is not None:
            self.map[curr.x + 1, curr.y + 1] = ord("O")
            curr = curr.next

    def _place_apple(self, apple: Apple) -> None:
        self.map[apple.x + 1, apple.y + 1] = ord("@")
