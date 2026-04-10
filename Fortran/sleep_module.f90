module sleep_module
    use iso_c_binding
    implicit none

    interface
        subroutine sleep_ms_c(ms) bind(c)
            import :: c_int
            integer(c_int), value :: ms
        end subroutine sleep_ms_c

        subroutine sleep_s_c(s) bind(c)
            import :: c_int
            integer(c_int), value :: s
        end subroutine sleep_s_c
    end interface

contains

    subroutine sleep_ms(ms)
        integer, intent(in) :: ms
        call sleep_ms_c(int(ms, c_int))
    end subroutine sleep_ms

    subroutine sleep_s(s)
        integer, intent(in) :: s
        call sleep_s_c(int(s, c_int))
    end subroutine sleep_s

end module sleep_module
