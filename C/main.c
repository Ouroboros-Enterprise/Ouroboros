#include "include/game.h"
#include "include/input.h"
#include "include/rng.h"
#include "include/sleep.h"
#include "include/terminal.h"

#include <stdbool.h>
#include <stdio.h>

int main()
{
    rng_init();

    bool play_again = true;

    int input;

    while (play_again)
    {
        clear_display();
        printf("--- OUROBOROS C ---\n");
        printf("Press SPACE to start or 'Q' to Quit...\n");

        for (;;)
        {
            input = get_key_press();

            if (input == ' ' || input == 13)
            {
                break;
            }

            if (input == 'q' || input == 'Q' || input == 27)
            {
                play_again = false;
                break;
            }

            sleep_ms(10);
        }

        if (!play_again)
        {
            break;
        }

        int start_x = get_random_int(0, 19);
        int start_y = get_random_int(0, 19);
        struct Game* game = create_game(start_x, start_y);

        if (game != NULL)
        {
            start(game);
            free_game(game);
        }

        printf("\n\nPress 'R' to Retry or 'Q' to Quit...\n");

        for (;;)
        {
            input = get_key_press();

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

            sleep_ms(10);
        }
    }

    hide_cursor();
    printf("\nThanks for playing!\n\n");

    for (int i = 5; i >= 0; --i)
    {
        printf("\rClosing in %d seconds...", i);
        fflush(stdout);
        sleep_ms(1000);
    }
    show_cursor();
    printf("\n");

    return 0;
}
