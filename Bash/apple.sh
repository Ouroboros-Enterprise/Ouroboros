if [[ -n "$APPLE_SH_LOADED" ]]; then return; fi
APPLE_SH_LOADED=1

source "$(dirname "$0")/snake.sh"

apple_x=0
apple_y=0

generate_apple() {
    for (( i=0; i<1000; i++ )); do
        local blocked=0

        local tx=$(( RANDOM % 20))
        local ty=$(( RANDOM % 20))

        for (( j=0; j<${#snake_x[@]}; j++ )); do
            if [[ ${snake_x[$j]} -eq $tx &&
                  ${snake_y[$j]} -eq $ty ]]; then
                blocked=1
                break
            fi
        done

        if [[ $blocked -eq 0 ]]; then
            apple_x=$tx
            apple_y=$ty
            return
        fi
    done
}
