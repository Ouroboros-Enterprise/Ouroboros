#pragma once

#include "makros.hpp"
#include "node.hpp"

class Snake : public Node
{
public:
    Snake(int _x, int _y, Node* _next)
            : Node(_x, _y, _next)
    {
    }

    ~Snake()
    {
        Node* curr = next;
        while (curr != nullptr)
        {
            Node* tmp = curr->next;
            delete curr;
            curr = tmp;
        }
    }

    [[nodiscard]] ALWAYS_INLINE bool move(int _x, int _y, bool grow) noexcept
    {
        Node* old_head_node = new Node(x, y, next);
        next = old_head_node;

        x = _x;
        y = _y;

        if (!grow && next != nullptr)
        {
            if (next->next == nullptr)
            {
                delete next;
                next = nullptr;
            }
            else
            {
                Node* curr = next;

                while (curr->next != nullptr && curr->next->next != nullptr)
                {
                    curr = curr->next;
                }

                delete curr->next;
                curr->next = nullptr;
            }
        }

        return !wallCollision() && !selfCollision();
    }

private:
    [[nodiscard]] ALWAYS_INLINE bool wallCollision() const noexcept
    {
        return x < 0 || x >= 20 || y < 0 || y >= 20;
    }

    [[nodiscard]] ALWAYS_INLINE bool selfCollision() const noexcept
    {
        Node* curr = next;

        while (curr != nullptr)
        {
            if (curr->x == x && curr->y == y)
            {
                return true;
            }
            curr = curr->next;
        }
        return false;
    }
};
