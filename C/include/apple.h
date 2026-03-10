#ifndef APPLE_H
#define APPLE_H

#include "makros.h"
#include "node.h"
#include "rng.h"
#include "snake.h"

#include <stdbool.h>
#include <stdlib.h>

struct Apple
{
    int x;
    int y;
};

static ALWAYS_INLINE void eat(struct Apple* apple, struct Snake* snake)
{
    for (int i = 0; i < 1000; ++i)
    {
        bool blocked = false;

        int x = get_random_int(0, 19);
        int y = get_random_int(0, 19);

        struct Node* curr = snake->head;

        while (curr != NULL)
        {
            if (curr->x == x && curr->y == y)
            {
                blocked = true;
                break;
            }
            curr = curr->next;
        }

        if (!blocked)
        {
            apple->x = x;
            apple->y = y;
            break;
        }
    }
}

static ALWAYS_INLINE struct Apple* create_apple(struct Snake* snake)
{
    struct Apple* new_apple = (struct Apple*)malloc(sizeof(struct Apple));

    if (new_apple != NULL)
    {
        eat(new_apple, snake);
    }

    return new_apple;
}

static ALWAYS_INLINE void free_apple(struct Apple* apple)
{
    free(apple);
}

#endif // APPLE_H
