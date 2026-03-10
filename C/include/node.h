#ifndef NODE_H
#define NODE_H

#include "makros.h"

#include <stdlib.h>

struct Node
{
    int x;
    int y;
    struct Node* next;
};

static ALWAYS_INLINE struct Node* create_node(int x, int y, struct Node* next)
{
    struct Node* new_node = (struct Node*)malloc(sizeof(struct Node));

    if (new_node != NULL)
    {
        new_node->x = x;
        new_node->y = y;
        new_node->next = next;
    }

    return new_node;
}

static ALWAYS_INLINE void free_node_chain(struct Node* node)
{
    struct Node* curr = node;
    struct Node* next;

    while (curr != NULL)
    {
        next = curr->next;

        free(curr);

        curr = next;
    }
}

#endif // NODE_H
