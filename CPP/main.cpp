#pragma once

#include "include/game.hpp"
#include "include/input.hpp"
#include "include/rng.hpp"

#include <chrono>
#include <iostream>
#include <thread>

int main()
{
    RandomNumberGenerator rng;

    bool play_again = true;

    int input;

    while (play_again)
    {
        int start_x = rng.generateRandomNumber(0, 19);
        int start_y = rng.generateRandomNumber(0, 19);

        Game game(start_x, start_y);

        std::cout << "\033[2J\033[H"; // Delete Terminal
        std::cout << "--- OUROBOROS C++ ---" << '\n';
        std::cout << "Press SPACE to start or 'Q' to Quit..." << '\n';

        for (;;) // Wait till start
        {
            input = getKeyPress();

            if (input == ' ' || input == 13)
            {
                break;
            }

            if (input == 'q' || input == 'Q' || input == 27)
            {
                play_again = false;
                break;
            }

            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }

        if (!play_again)
        {
            break;
        }

        game.start();

        std::cout << "\n\nPress 'R' to Retry or 'Q' to Quit..." << '\n';

        for (;;)
        {
            input = getKeyPress();

            if (input == 'r' || input == 'R')
            {
                play_again = true;
                break;
            }
            if (input == 'q' || input == 'Q' || input == 27)
            {
                play_again = false;
                break;
            }

            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
    }

    std::cout << "\nThanks for playing!" << '\n';

    for (int i = 5; i >= 0; --i)
    {
        std::cout << i << '\n';
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    return 0;
}
