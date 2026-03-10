#ifndef SNAKE_H
#define SNAKE_H

#include "makros.h"
#include "node.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>

struct Snake
{
    struct Node* head;
};

static ALWAYS_INLINE struct Snake* create_snake(int x, int y, struct Node* next)
{
    struct Snake* new_snake = (struct Snake*)malloc(sizeof(struct Snake));

    if (new_snake != NULL)
    {
        new_snake->head = create_node(x, y, next);
    }

    return new_snake;
}

static ALWAYS_INLINE void free_snake(struct Snake* snake)
{
    free_node_chain(snake->head);
    free(snake);
}

static ALWAYS_INLINE bool wall_collision(struct Snake* snake)
{
    int x = snake->head->x;
    int y = snake->head->y;

    return x < 0 || x >= 20 || y < 0 || y >= 20;
}

static ALWAYS_INLINE bool self_collision(struct Snake* snake)
{
    struct Node* curr = snake->head->next;

    int x = snake->head->x;
    int y = snake->head->y;

    while (curr != NULL)
    {
        if (curr->x == x && curr->y == y)
        {
            return true;
        }
        curr = curr->next;
    }
    return false;
}

static ALWAYS_INLINE bool move_snake(struct Snake* snake, int nx, int ny,
                                     bool grow)
{
    struct Node* head = snake->head;

    struct Node* old_head = create_node(head->x, head->y, head->next);

    if (old_head == NULL)
    {
        return false;
    }

    head->next = old_head;

    head->x = nx;
    head->y = ny;

    if (!grow && head->next != NULL)
    {
        if (head->next->next == NULL)
        {
            free(head->next);
            head->next = NULL;
        }
        else
        {
            struct Node* curr = head->next;

            while (curr->next != NULL && curr->next->next != NULL)
            {
                curr = curr->next;
            }

            free(curr->next);
            curr->next = NULL;
        }
    }

    return !wall_collision(snake) && !self_collision(snake);
}

#endif // SNAKE_H
