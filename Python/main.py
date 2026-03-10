from game import Game
from input import get_key_press
from sleep import sleep_ms, sleep_s
from terminal import hide_cursor, show_cursor, clear_display
from sys import stdout
from random import randint


def main() -> None:
    play_again: bool = True

    start = (ord(" "), 13)
    quit = (ord("q"), ord("Q"), 27)
    retry = (ord("r"), ord("R"))

    while play_again:
        clear_display()

        stdout.write("--- OUROBOROS Python ---\n")
        stdout.write("Press SPACE to start or 'Q' to Quit...\n")

        while True:
            input: int = get_key_press()

            if input in start:
                break

            if input in quit:
                play_again = False
                break

            sleep_ms(10)

        if not play_again:
            break

        start_x: int = randint(0, 19)
        start_y: int = randint(0, 19)

        game: Game = Game(start_x, start_y)

        game.start()

        stdout.write("\n\nPress 'R' to Retry or 'Q' to Quit...\n")

        while True:
            input = get_key_press()

            if input in retry:
                play_again = True
                break
            if input in quit:
                play_again = False
                break

            sleep_ms(10)

    hide_cursor()
    stdout.write("\nThanks for playing!\n\n")

    for i in range(5, -1, -1):
        stdout.write(f"\rClosing in {i} seconds...")
        stdout.flush()
        sleep_s(1)

    show_cursor()
    stdout.write("\n")


if __name__ == "__main__":
    main()
