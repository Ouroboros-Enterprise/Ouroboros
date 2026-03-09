#pragma once

#include "apple.hpp"
#include "makros.hpp"
#include "snake.hpp"
#include "terminal.hpp"

#include <array>

class GUI
{
    std::array<std::array<char, 22>, 22> map;

public:
    GUI() = default;
    ~GUI() = default;

    ALWAYS_INLINE void genGui(Snake* snake, Apple* apple, int score) noexcept
    {
        char field;

        gotoXY(1, 1);

        for (auto& row : map)
        {
            row.fill(' ');
        }

        placeBorders();
        placeSnake(snake);
        placeApple(apple);

        for (int j = 0; j < 22; ++j)
        {
            for (int i = 0; i < 22; ++i)
            {
                field = map[i][j];

                if (field == '#')
                {
                    std::cout << "##";
                }
                else
                {
                    std::cout << field << ' ';
                }
            }

            if (j == 0)
            {
                std::cout << "  Score:  " << score;
            }

            std::cout << '\n';
        }
    }

    ALWAYS_INLINE void gameOver()
    {
        gotoXY(1, 23);
        std::cout << "         ___                 " << '\n';
        std::cout << "        / __|__ _ _ __  ___  " << '\n';
        std::cout << "       | (_ / _` | ''  \\/ -_) " << '\n';
        std::cout << "        \\___\\__,_|_|_|_\\___| " << '\n';
        std::cout << "         ___                 " << '\n';
        std::cout << "        / _ \\_ _____ _ _     " << '\n';
        std::cout << "       | (_) \\ V / -_) ''_|   " << '\n';
        std::cout << "        \\___/ \\_/\\___|_|     " << '\n';
    }

private:
    ALWAYS_INLINE void placeBorders() noexcept
    {
        for (int i = 0; i < 22; ++i)
        {
            map[0][i] = '#';
            map[21][i] = '#';
            map[i][0] = '#';
            map[i][21] = '#';
        }
    }

    ALWAYS_INLINE void placeSnake(Snake* snake) noexcept
    {
        if (!snake) [[unlikely]]
        {
            return;
        }

        Node* curr = snake;

        map[curr->x + 1][curr->y + 1] = 'X';
        curr = curr->next;

        while (curr != nullptr)
        {
            map[curr->x + 1][curr->y + 1] = 'O';
            curr = curr->next;
        }
    }

    ALWAYS_INLINE void placeApple(Apple* apple) noexcept
    {
        map[apple->getX() + 1][apple->getY() + 1] = '@';
    }
};
