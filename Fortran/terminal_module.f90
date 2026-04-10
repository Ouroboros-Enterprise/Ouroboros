module terminal_module
    implicit none

contains

    subroutine goto_xy(x, y)
        integer, intent(in) :: x, y
        write(*, '(A, I0, A, I0, A)', advance='no') char(27) // '[', y, ';', x, 'H'
        call flush(6)
    end subroutine goto_xy

    subroutine hide_cursor()
        write(*, '(A)', advance='no') char(27) // '[?25l'
        call flush(6)
    end subroutine hide_cursor

    subroutine show_cursor()
        write(*, '(A)', advance='no') char(27) // '[?25h'
        call flush(6)
    end subroutine show_cursor

    subroutine clear_display()
        write(*, '(A)', advance='no') char(27) // '[2J' // char(27) // '[H'
        call flush(6)
    end subroutine clear_display

end module terminal_module
