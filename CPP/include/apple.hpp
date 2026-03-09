#pragma once

#include "makros.hpp"
#include "node.hpp"
#include "rng.hpp"
#include "snake.hpp"

class Apple
{
    int x;
    int y;

    RandomNumberGenerator& rng;

public:
    Apple(Snake* snake, RandomNumberGenerator& extRNG)
            : rng(extRNG)
    {
        eat(snake);
    }

    ALWAYS_INLINE void eat(Snake* snake) noexcept
    {
        for (int i = 0; i < 1000; ++i)
        {
            bool blocked = false;

            int _x = rng.generateRandomNumber(0, 19);
            int _y = rng.generateRandomNumber(0, 19);

            Node* curr = snake;

            while (curr != nullptr)
            {
                if (curr->x == _x && curr->y == _y)
                {
                    blocked = true;
                    break;
                }
                curr = curr->next;
            }

            if (!blocked)
            {
                x = _x;
                y = _y;
                break;
            }
        }
    }

    [[nodiscard]] ALWAYS_INLINE int getX() const noexcept
    {
        return x;
    }

    [[nodiscard]] ALWAYS_INLINE int getY() const noexcept
    {
        return y;
    }
};
