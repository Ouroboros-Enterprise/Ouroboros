program main
    use types_module
    use game_module
    use input_module
    use sleep_module
    use terminal_module
    implicit none

    logical :: play_again
    integer :: input, i, start_x, start_y
    real :: r

    play_again = .true.

    call random_seed()

    do while (play_again)
        call clear_display()
        write(*, '(A)') "--- OUROBOROS Fortran ---"
        write(*, '(A)') "Press SPACE to start or 'Q' to Quit..."

        do
            input = get_key_press()

            if (input == 32 .or. input == 13) exit ! SPACE or ENTER
            if (input == 113 .or. input == 81 .or. input == 27) then ! q, Q or ESC
                play_again = .false.
                exit
            end if

            call sleep_ms(10)
        end do

        if (.not. play_again) exit

        call random_number(r)
        start_x = int(r * 20.0)
        call random_number(r)
        start_y = int(r * 20.0)

        call start_game(start_x, start_y)

        write(*, '(A)') ""
        write(*, '(A)') "Press 'R' to Retry or 'Q' to Quit..."

        do
            input = get_key_press()

            if (input == 114 .or. input == 82) then ! r, R
                play_again = .true.
                exit
            end if
            if (input == 113 .or. input == 81 .or. input == 27) then ! q, Q or ESC
                play_again = .false.
                exit
            end if

            call sleep_ms(10)
        end do
    end do

    call hide_cursor()
    write(*, '(A)') ""
    write(*, '(A)') "Thanks for playing!"
    write(*, '(A)') ""

    do i = 5, 0, -1
        write(*, '(A, I0, A)', advance='no') char(13) // "Closing in ", i, " seconds..."
        call flush(6)
        call sleep_s(1)
    end do

    call show_cursor()
    write(*, '(A)') ""

end program main
