if [[ -n "$GUI_SH_LOADED" ]]; then return; fi
GUI_SH_LOADED=1

source "$(dirname "$0")/snake.sh"
source "$(dirname "$0")/apple.sh"

map=()
width=22
height=22
total_fields=$(( width * height ))

gui_init() {
    for (( i=0; i<total_fields; i++ )); do
        map[$i]=" "
    done
}

get_map_idx() {
    local mx=$1
    local my=$2
    echo $(( (my * width) + mx ))
}

get_map_x() {
    local midx=$1
    echo $(( midx % height ))
}

get_map_y() {
    local midx=$1
    echo $(( midx / width ))
}

place_map_borders() {
    for (( i=0; i<width; i++ )); do
        map[$(get_map_idx 0 $i)]="#"
        map[$(get_map_idx 21 $i)]="#"
        map[$(get_map_idx $i 0)]="#"
        map[$(get_map_idx $i 21)]="#"
    done
}

place_map_snake() {
    map[$(get_map_idx $(( snake_x[0] + 1 )) $(( snake_y[0] + 1 )))]="X"

    for (( i=1; i<${#snake_x[@]}; i++ )); do
        map[$(get_map_idx $(( snake_x[$i] + 1)) $(( snake_y[$i] + 1 )))]="O"
    done
}

place_map_apple() {
    map[$(get_map_idx $(( apple_x + 1 )) $(( apple_y + 1 )))]="@"
}

generate_gui() {
    local score=$1
    local out=""

    gui_init

    place_map_borders
    place_map_snake
    place_map_apple

    out+="\x1B[1;1H"

    for (( i=0; i<total_fields; i++ )); do
        local field="${map[$i]}"

        if [[ "$field" == "#" ]]; then
            out+="##"
        else
            out+="$field "
        fi

        if [[ $(( (i + 1) % width )) -eq 0 ]]; then
            if [[ $i -lt width ]]; then
                out+="  Score:  $score"
            fi

            out+="\x1B[K\n"
        fi
    done

    printf "%b" "$out"
}

game_over() {
    printf "\x1B[23;1H"
    
    cat << 'EOF'
         ___                 
        / __|__ _ _ __  ___  
       | (_ / _` | '  \/ -_) 
        \___\__,_|_|_|_\___| 
         ___                 
        / _ \_ _____ _ _     
       | (_) \ V / -_) '_|    
        \___/ \_/\___|_|     

EOF
}
