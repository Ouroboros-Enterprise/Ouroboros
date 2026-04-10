module gui_module
    use types_module
    use terminal_module
    implicit none

    type gui_type
        integer, dimension(0:21, 0:21) :: map
    end type gui_type

contains

    subroutine gen_gui(gui, snake, apple, score)
        type(gui_type), intent(inout) :: gui
        type(snake_type), intent(in) :: snake
        type(apple_type), intent(in) :: apple
        integer, intent(in) :: score
        integer :: i, j
        type(node_type), pointer :: curr
        character(len=2) :: row_str

        call goto_xy(1, 1)

        gui%map = ichar(' ')

        ! Borders
        gui%map(0, :) = ichar('#')
        gui%map(21, :) = ichar('#')
        gui%map(:, 0) = ichar('#')
        gui%map(:, 21) = ichar('#')

        ! Snake
        gui%map(snake%x + 1, snake%y + 1) = ichar('X')
        curr => snake%next
        do while (associated(curr))
            gui%map(curr%x + 1, curr%y + 1) = ichar('O')
            curr => curr%next
        end do

        ! Apple
        gui%map(apple%x + 1, apple%y + 1) = ichar('@')

        do j = 0, 21
            do i = 0, 21
                if (gui%map(i, j) == ichar('#')) then
                    write(*, '(A)', advance='no') '##'
                else
                    write(*, '(A, A)', advance='no') char(gui%map(i, j)), ' '
                end if
            end do
            if (j == 0) then
                write(*, '(A, I0)', advance='no') '  Score:  ', score
            end if
            write(*, *)
        end do
        call flush(6)
    end subroutine gen_gui

    subroutine game_over()
        call goto_xy(1, 23)
        write(*, '(A)') "         ___                 "
        write(*, '(A)') "        / __|__ _ _ __  ___  "
        write(*, '(A)') "       | (_ / _` | ''  \/ -_) "
        write(*, '(A)') "        \___\__,_|_|_|_\___| "
        write(*, '(A)') "         ___                 "
        write(*, '(A)') "        / _ \_ _____ _ _     "
        write(*, '(A)') "       | (_) \ V / -_) ''_|   "
        write(*, '(A)') "        \___/ \_/\___|_|     "
    end subroutine game_over

end module gui_module
