#pragma once

struct Node
{
    int x;
    int y;
    Node* next;

    Node(int _x, int _y, Node* _next)
            : x(_x)
            , y(_y)
            , next(_next)
    {
    }
};
