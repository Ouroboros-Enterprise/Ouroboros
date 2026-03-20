#!/bin/bash

trap "stty sane; printf '\x1B[?25h'; exit" SIGINT SIGTERM

source "$(dirname "$0")/game.sh"

play_again=1

while [[ $play_again -eq 1 ]]; do
    printf "\x1B[2J\x1B[H"
    printf "--- OUROBOROS Bash ---\n"
    printf "Press SPACE to start or 'Q' to Quit...\n"

    while true; do
        IFS= read -rsn1 -t 0.1 input

        case "$input" in
            " ") break ;;
            q|Q) play_again=0; break ;;
        esac

        sleep 0.01
    done

    if [[ $play_again -eq 0 ]]; then
        break
    fi

    start_x=$(( RANDOM % 20))
    start_y=$(( RANDOM % 20))

    game_init "$start_x" "$start_y"

    start_game

    printf "\n\nPress 'R' to Retry or 'Q' to Quit...\n"

    while true; do
        read -rsn1 -t 0.1 input

        case "$input" in
            r|R) break ;;
            q|Q) play_again=0; break ;;
        esac

        sleep 0.01
    done
done

printf "\x1B[?25l"
printf "\nThanks for playing!\n\n"

for (( i=5; i>=0; i-- )); do
    printf "\rClosing in %d seconds..." "$i"
    sleep 1
done

printf "\x1B[?25h"
printf "\n"
stty sane
