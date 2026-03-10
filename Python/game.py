from snake import Snake
from apple import Apple
from gui import GUI
from node import Node
from input import get_key_press, wait_for_exit
from sleep import sleep_ms
from terminal import hide_cursor, show_cursor


class Game:
    def __init__(self, start_x: int, start_y: int) -> None:
        self.snake: Snake = Snake(start_x, start_y, Node(1, 2, None))
        self.apple: Apple = Apple(self.snake)
        self.gui: GUI = GUI()
        self.apple_count: int = 0

    def start(self) -> None:
        hide_cursor()

        dx: int = 1
        dy: int = 0
        running: bool = True

        while True:
            input: int = get_key_press()

            match input:
                # UP: 'w', 'W' oder Pfeiltaste oben (72)
                case 119 | 87 | 72:
                    if dy != 1:
                        dx, dy = 0, -1

                # DOWN: 's', 'S' oder Pfeiltaste unten (80)
                case 115 | 83 | 80:
                    if dy != -1:
                        dx, dy = 0, 1

                # LEFT: 'a', 'A' oder Pfeiltaste links (75)
                case 97 | 65 | 75:
                    if dx != 1:
                        dx, dy = -1, 0

                # RIGHT: 'd', 'D' oder Pfeiltaste rechts (77)
                case 100 | 68 | 77:
                    if dx != -1:
                        dx, dy = 1, 0

                # QUIT: 'q', 'Q' oder ESC (27)
                case 113 | 81 | 27:
                    running = False

            if not running:
                break

            ax: int = self.snake.x + dx
            ay: int = self.snake.y + dy

            grow: bool = ax == self.apple.x and ay == self.apple.y
            if grow:
                self.apple.eat(self.snake)
                self.apple_count += 1

            if not self.snake.move(ax, ay, grow):
                break

            self.gui.gen_gui(self.snake, self.apple, self.apple_count)

            sleep_ms(300)

        self.gui.game_over()
        show_cursor()
        wait_for_exit()
