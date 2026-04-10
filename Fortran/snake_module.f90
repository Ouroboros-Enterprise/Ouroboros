module snake_module
    use types_module
    implicit none

contains

    function move_snake(snake, x, y, grow) result(alive)
        type(snake_type), intent(inout) :: snake
        integer, intent(in) :: x, y
        logical, intent(in) :: grow
        logical :: alive
        type(node_type), pointer :: old_head, curr

        allocate(old_head)
        old_head%x = snake%x
        old_head%y = snake%y
        old_head%next => snake%next

        snake%x = x
        snake%y = y
        snake%next => old_head

        if (.not. grow .and. associated(snake%next)) then
            if (.not. associated(snake%next%next)) then
                deallocate(snake%next)
                snake%next => null()
            else
                curr => snake%next
                do while (associated(curr%next))
                    if (.not. associated(curr%next%next)) exit
                    curr => curr%next
                end do
                deallocate(curr%next)
                curr%next => null()
            end if
        end if

        alive = .not. self_collision(snake) .and. .not. wall_collision(snake)
    end function move_snake

    function wall_collision(snake) result(collision)
        type(snake_type), intent(in) :: snake
        logical :: collision
        collision = snake%x < 0 .or. snake%x >= 20 .or. snake%y < 0 .or. snake%y >= 20
    end function wall_collision

    function self_collision(snake) result(collision)
        type(snake_type), intent(in) :: snake
        logical :: collision
        type(node_type), pointer :: curr
        collision = .false.
        curr => snake%next
        do while (associated(curr))
            if (curr%x == snake%x .and. curr%y == snake%y) then
                collision = .true.
                return
            end if
            curr => curr%next
        end do
    end function self_collision

end module snake_module
