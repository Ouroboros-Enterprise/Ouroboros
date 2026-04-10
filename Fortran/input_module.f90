module input_module
    use iso_c_binding
    implicit none

    interface
        integer(c_int) function get_key_press_c() bind(c)
            import :: c_int
        end function get_key_press_c

        subroutine wait_for_exit_c() bind(c)
        end subroutine wait_for_exit_c
    end interface

contains

    integer function get_key_press()
        get_key_press = int(get_key_press_c())
    end function get_key_press

    subroutine wait_for_exit()
        call wait_for_exit_c()
    end subroutine wait_for_exit

end module input_module
