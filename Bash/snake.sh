if [[ -n "$SNAKE_SH_LOADED" ]]; then return; fi
SNAKE_SH_LOADED=1

snake_x=()
snake_y=()

snake_init() {
    local start_x=$1
    local start_y=$2
    snake_x=("$start_x" "$start_x")
    snake_y=("$start_y" "$((start_y + 1))")
}

snake_push_head() {
    local new_x=$1
    local new_y=$2
    snake_x=($new_x "${snake_x[@]}")
    snake_y=($new_y "${snake_y[@]}")
}

snake_pop_tail() {
    unset 'snake_x[${#snake_x[@]}-1]'
    unset 'snake_y[${#snake_y[@]}-1]'
    snake_x=("${snake_x[@]}")
    snake_y=("${snake_y[@]}")
}

wall_collision() {
    if [[ ${snake_x[0]} -lt 0 || ${snake_x[0]} -ge 20 ||
          ${snake_y[0]} -lt 0 || ${snake_y[0]} -ge 20 ]]; then
        return 0
    else
        return 1
    fi
}

self_collision() {
    for (( i=1; i<${#snake_x[@]}; i++ )); do
        if [[ ${snake_x[$i]} -eq ${snake_x[0]} &&
              ${snake_y[$i]} -eq ${snake_y[0]} ]]; then
            return 0
        fi
    done
    return 1
}

move_snake() {
    local new_x=$1
    local new_y=$2
    local grow=$3

    snake_push_head "$new_x" "$new_y"

    if [[ $grow -eq 0 ]]; then
        snake_pop_tail
    fi

    if wall_collision || self_collision; then
        return 1
    fi
    return 0
}