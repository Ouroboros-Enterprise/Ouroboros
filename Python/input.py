import os

if os.name == "nt":
    from msvcrt import kbhit, getch

    def get_key_press() -> int:
        if kbhit():
            return ord(getch())
        return -1

    def wait_for_exit() -> None:
        # Puffer leeren
        while kbhit():
            getch()
        print("\nPress a key to exit...")
        getch()

else:
    from termios import tcgetattr, tcsetattr, TCSADRAIN
    from tty import setraw
    from select import select
    from sys import stdin, stdout

    def get_key_press() -> int:
        fd = stdin.fileno()
        old_settings = tcgetattr(fd)
        try:
            setraw(fd)
            if select([stdin], [], [], 0) == ([stdin], [], []):
                return ord(stdin.read(1))
            return -1
        finally:
            tcsetattr(fd, TCSADRAIN, old_settings)

    def wait_for_exit() -> None:
        stdout.write("\nPress a key to exit...")
        stdout.flush()

        fd = stdin.fileno()
        old_settings = tcgetattr(fd)
        try:
            setraw(fd)
            stdin.read(1)
        finally:
            tcsetattr(fd, TCSADRAIN, old_settings)
