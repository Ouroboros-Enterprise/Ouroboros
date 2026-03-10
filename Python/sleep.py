import time


def sleep_ms(milliseconds: int) -> None:
    time.sleep(milliseconds / 1000.0)


def sleep_s(seconds: int) -> None:
    time.sleep(seconds)
