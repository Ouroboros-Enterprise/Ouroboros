module game_module
    use types_module
    use snake_module
    use apple_module
    use gui_module
    use input_module
    use sleep_module
    use terminal_module
    implicit none

contains

    subroutine start_game(start_x, start_y)
        integer, intent(in) :: start_x, start_y
        type(snake_type) :: snake
        type(apple_type) :: apple
        type(gui_type) :: gui
        integer :: apple_count, dx, dy, input, ax, ay
        logical :: running, grow, alive

        allocate(snake%next)
        snake%x = start_x
        snake%y = start_y
        snake%next%x = 1
        snake%next%y = 2
        snake%next%next => null()

        call init_apple(apple, snake)
        apple_count = 0

        call hide_cursor()

        dx = 1
        dy = 0
        running = .true.

        do while (running)
            input = get_key_press()

            select case (input)
                ! UP: 'w', 'W' or UP arrow (this might be platform dependent)
                case (119, 87, 72)
                    if (dy /= 1) then
                        dx = 0
                        dy = -1
                    end if
                ! DOWN: 's', 'S' or DOWN arrow
                case (115, 83, 80)
                    if (dy /= -1) then
                        dx = 0
                        dy = 1
                    end if
                ! LEFT: 'a', 'A' or LEFT arrow
                case (97, 65, 75)
                    if (dx /= 1) then
                        dx = -1
                        dy = 0
                    end if
                ! RIGHT: 'd', 'D' or RIGHT arrow
                case (100, 68, 77)
                    if (dx /= -1) then
                        dx = 1
                        dy = 0
                    end if
                ! QUIT: 'q', 'Q' or ESC
                case (113, 81, 27)
                    running = .false.
            end select

            if (.not. running) exit

            ax = snake%x + dx
            ay = snake%y + dy

            grow = (ax == apple%x .and. ay == apple%y)
            if (grow) then
                call eat_apple(apple, snake)
                apple_count = apple_count + 1
            end if

            alive = move_snake(snake, ax, ay, grow)
            if (.not. alive) exit

            call gen_gui(gui, snake, apple, apple_count)
            call sleep_ms(300)
        end do

        call game_over()
        call show_cursor()
        call wait_for_exit()
        
        ! Cleanup
        call free_snake(snake)
    end subroutine start_game

    subroutine free_snake(snake)
        type(snake_type), intent(inout) :: snake
        type(node_type), pointer :: curr, next_node
        curr => snake%next
        do while (associated(curr))
            next_node => curr%next
            deallocate(curr)
            curr => next_node
        end do
        snake%next => null()
    end subroutine free_snake

end module game_module
