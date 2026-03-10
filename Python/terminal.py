from sys import stdout


def goto_xy(x: int, y: int) -> None:
    stdout.write(f"\033[{y};{x}H")
    stdout.flush()


def hide_cursor() -> None:
    stdout.write("\033[?25l")
    stdout.flush()


def show_cursor() -> None:
    stdout.write("\033[?25h")
    stdout.flush()


def clear_display() -> None:
    stdout.write("\033[2J\033[H")
    stdout.flush()
