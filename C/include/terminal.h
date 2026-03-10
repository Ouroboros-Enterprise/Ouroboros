#ifndef TERMINAL_H
#define TERMINAL_H

#include "makros.h"

#include <stdio.h>

static ALWAYS_INLINE void goto_xy(int x, int y)
{
    printf("\033[%d;%dH", y, x);

    fflush(stdout);
}

static ALWAYS_INLINE void hide_cursor()
{
    printf("\033[?25l");
    fflush(stdout);
}

static ALWAYS_INLINE void show_cursor()
{
    printf("\033[?25h");
    fflush(stdout);
}

static ALWAYS_INLINE void clear_display()
{
    printf("\033[2J\033[H");
    fflush(stdout);
}

#endif
