if [[ -n "$GAME_SH_LOADED" ]]; then return; fi
GAME_SH_LOADED=1

source "$(dirname "$0")/snake.sh"
source "$(dirname "$0")/apple.sh"
source "$(dirname "$0")/gui.sh"

score=0
current_dir="d"

game_init() {
    local start_x=$1
    local start_y=$2
    score=0
    current_dir="d"
    snake_init $start_x $start_y
    generate_apple
    gui_init
}

read_input() {
    local key
    read -rsn1 -t 0.1 key

    case "$key" in
        w|W) [[ "$current_dir" != "s" ]] && current_dir="w" ;;
        s|S) [[ "$current_dir" != "w" ]] && current_dir="s" ;;
        a|A) [[ "$current_dir" != "d" ]] && current_dir="a" ;;
        d|D) [[ "$current_dir" != "a" ]] && current_dir="d" ;;
        q|Q) current_dir="q" ;;
    esac
}

start_game() {
    printf "\x1B[?25l"

    stty -echo -icanon time 0 min 0

    local running=1

    while true; do
        read_input

        local ax=${snake_x[0]}
        local ay=${snake_y[0]}

        case "${current_dir}" in
            w) (( ay-- )) ;;
            s) (( ay++ )) ;;
            a) (( ax-- )) ;;
            d) (( ax++ )) ;;
            q) running=0 ;;
        esac

        if [[ $running -eq 0 ]]; then
            break
        fi

        local grow=$([[ $ax -eq $apple_x && $ay -eq $apple_y ]] && echo 1 || echo 0)

        if [[ $grow -eq 1 ]]; then
            generate_apple
            (( score++ ))
        fi

        if ! move_snake "$ax" "$ay" "$grow"; then
            break
        fi

        generate_gui $score

        sleep 0.3
    done

    game_over

    stty sane
    printf "\x1B[?25h"

    while read -rsn1 -t 0.01; do :; done

    printf "Press a key to exit...\n"
    read -rsn1
}
