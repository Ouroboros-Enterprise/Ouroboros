#ifndef GUI_H
#define GUI_H

#include "apple.h"
#include "makros.h"
#include "snake.h"
#include "terminal.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct GUI
{
    char map[22][22];
};

static ALWAYS_INLINE struct GUI* create_gui()
{
    struct GUI* new_gui = (struct GUI*)malloc(sizeof(struct GUI));

    if (new_gui != NULL)
    {
        memset(new_gui->map, 0, sizeof(new_gui->map));
    }

    return new_gui;
}

static ALWAYS_INLINE void free_gui(struct GUI* gui)
{
    free(gui);
}

static ALWAYS_INLINE void place_borders(struct GUI* gui)
{
    char (*map)[22] = gui->map;

    for (int i = 0; i < 22; ++i)
    {
        map[0][i] = '#';
        map[21][i] = '#';
        map[i][0] = '#';
        map[i][21] = '#';
    }
}

static ALWAYS_INLINE void place_snake(struct GUI* gui, struct Snake* snake)
{
    if (snake == NULL || snake->head == NULL)
    {
        return;
    }

    char (*map)[22] = gui->map;

    struct Node* curr = snake->head;

    map[curr->x + 1][curr->y + 1] = 'X';

    curr = curr->next;

    while (curr != NULL)
    {
        map[curr->x + 1][curr->y + 1] = 'O';
        curr = curr->next;
    }
}

static ALWAYS_INLINE void place_apple(struct GUI* gui, struct Apple* apple)
{
    char (*map)[22] = gui->map;

    map[apple->x + 1][apple->y + 1] = '@';
}

static ALWAYS_INLINE void gen_gui(struct GUI* gui, struct Snake* snake,
                                  struct Apple* apple, int score)
{
    char field;
    char (*map)[22] = gui->map;

    goto_xy(1, 1);

    memset(gui->map, ' ', sizeof(gui->map));

    place_borders(gui);
    place_snake(gui, snake);
    place_apple(gui, apple);

    for (int j = 0; j < 22; ++j)
    {
        for (int i = 0; i < 22; ++i)
        {
            field = map[i][j];

            if (field == '#')
            {
                printf("##");
            }
            else
            {
                printf("%c ", field);
            }
        }

        if (j == 0)
        {
            printf("  Score:  %d", score);
        }

        printf("\n");
    }
}

static ALWAYS_INLINE void game_over()
{
    goto_xy(1, 23);

    printf("         ___                 \n");
    printf("        / __|__ _ _ __  ___  \n");
    printf("       | (_ / _` | ''  \\/ -_) \n");
    printf("        \\___\\__,_|_|_|_\\___| \n");
    printf("         ___                 \n");
    printf("        / _ \\_ _____ _ _     \n");
    printf("       | (_) \\ V / -_) ''_|   \n");
    printf("        \\___/ \\_/\\___|_|     \n");
}

#endif // GUI_H
