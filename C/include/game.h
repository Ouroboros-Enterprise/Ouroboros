#ifndef GAME_H
#define GAME_H

#include "apple.h"
#include "gui.h"
#include "input.h"
#include "makros.h"
#include "node.h"
#include "sleep.h"
#include "snake.h"
#include "terminal.h"

#include <conio.h>
#include <corecrt.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>

struct Game
{
    int apple_count;
    struct Snake* snake;
    struct Apple* apple;
    struct GUI* gui;
};

static ALWAYS_INLINE struct Game* create_game(int start_x, int start_y)
{
    struct Game* new_game = (struct Game*)malloc(sizeof(struct Game));

    if (new_game != NULL)
    {
        new_game->apple_count = 0;
        new_game->snake =
            create_snake(start_x, start_y, create_node(1, 2, NULL));
        new_game->apple = create_apple(new_game->snake);
        new_game->gui = create_gui();
    }

    return new_game;
}

static ALWAYS_INLINE void free_game(struct Game* game)
{
    free_snake(game->snake);
    free_apple(game->apple);
    free_gui(game->gui);
    free(game);
}

static ALWAYS_INLINE void start(struct Game* game)
{
    hide_cursor();

    struct Snake* snake = game->snake;
    struct Apple* apple = game->apple;
    struct GUI* gui = game->gui;

    int input;
    int dx = 1;
    int dy = 0;
    int ax, ay;
    bool grow;
    bool running = true;

    for (;;)
    {
        input = get_key_press();

        switch (input)
        {
            case 'w':
            case 'W':
            case 72:
                if (dy != 1)
                {
                    dx = 0;
                    dy = -1;
                }
                break;
            case 's':
            case 'S':
            case 80:
                if (dy != -1)
                {
                    dx = 0;
                    dy = 1;
                }
                break;
            case 'a':
            case 'A':
            case 75:
                if (dx != 1)
                {
                    dx = -1;
                    dy = 0;
                }
                break;
            case 'd':
            case 'D':
            case 77:
                if (dx != -1)
                {
                    dx = 1;
                    dy = 0;
                }
                break;
            case 'q':
            case 'Q':
            case 27:
                running = false;
                break;
        }
        // True if Quit Key is pressed
        if (!running)
        {
            break;
        }

        ax = snake->head->x + dx;
        ay = snake->head->y + dy;

        grow = (ax == apple->x && ay == apple->y);
        if (grow)
        {
            eat(apple, snake);
            ++game->apple_count;
        }

        if (!move_snake(snake, ax, ay, grow))
        {
            break;
        }

        gen_gui(gui, snake, apple, game->apple_count);

        sleep_ms(300);
    }
    game_over();
    show_cursor();

#ifdef _WIN32
    while (_kbhit())
    {
        _getch();
    }
    _getch(); // Closes when key pressed
#else
    printf("Press Enter to exit...\n");

    int c;
    while ((c = getchar()) != '\n' && c != EOF)
        ;

    getchar();
#endif
}

#endif // GAME_H
