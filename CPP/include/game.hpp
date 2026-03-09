#pragma once

#include "apple.hpp"
#include "gui.hpp"
#include "input.hpp"
#include "makros.hpp"
#include "node.hpp"
#include "snake.hpp"

#include <chrono>
#include <conio.h>
#include <ostream>
#include <thread>

class Game
{
    Snake snake;
    Apple apple;
    int apple_count = 0;
    GUI gui;
    RandomNumberGenerator rng;

public:
    Game(int start_x, int start_y)
            : snake(start_x, start_y, new Node(1, 2, nullptr))
            , apple(&snake, rng)
            , gui()
    {
    }

    ~Game() = default;

    ALWAYS_INLINE void start() noexcept
    {
        std::cout << "\033[?25l" << std::flush;

        int input;
        int dx = 1;
        int dy = 0;
        int ax, ay;
        bool grow;
        bool running = true;

        for (;;)
        {
            input = getKeyPress();

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

            ax = snake.x + dx;
            ay = snake.y + dy;

            // Grow
            grow = (ax == apple.getX() && ay == apple.getY());
            if (grow)
            {
                apple.eat(&snake);
                ++apple_count;
            }

            // Move logic + collision detection
            if (!snake.move(ax, ay, grow))
            {
                break;
            }

            gui.genGui(&snake, &apple, apple_count);
            std::this_thread::sleep_for(std::chrono::milliseconds(300));
        }
        gui.gameOver();
        std::cout << "\033[?25h" << std::flush;
#ifdef _WIN32
        while (_kbhit())
        {
            _getch();
        }
        _getch(); // Closes when key pressed
#else
        std::cout << "Press Enter to exit..." << '\n';
        std::cin.ignore();
        std::cin.get();
#endif
    }
};
