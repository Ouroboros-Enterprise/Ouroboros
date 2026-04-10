module apple_module
    use types_module
    implicit none

contains

    subroutine init_apple(apple, snake)
        type(apple_type), intent(out) :: apple
        type(snake_type), intent(in) :: snake
        call eat_apple(apple, snake)
    end subroutine init_apple

    subroutine eat_apple(apple, snake)
        type(apple_type), intent(inout) :: apple
        type(snake_type), intent(in) :: snake
        integer :: i, x, y
        logical :: blocked
        type(node_type), pointer :: curr
        real :: r

        do i = 1, 1000
            blocked = .false.
            call random_number(r)
            x = int(r * 20.0)
            call random_number(r)
            y = int(r * 20.0)

            if (snake%x == x .and. snake%y == y) then
                blocked = .true.
            else
                curr => snake%next
                do while (associated(curr))
                    if (curr%x == x .and. curr%y == y) then
                        blocked = .true.
                        exit
                    end if
                    curr => curr%next
                end do
            end if

            if (.not. blocked) then
                apple%x = x
                apple%y = y
                return
            end if
        end do
    end subroutine eat_apple

end module apple_module
