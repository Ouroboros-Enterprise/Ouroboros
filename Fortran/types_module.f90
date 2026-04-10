module types_module
    implicit none

    type node_type
        integer :: x
        integer :: y
        type(node_type), pointer :: next => null()
    end type node_type

    type snake_type
        integer :: x
        integer :: y
        type(node_type), pointer :: next => null()
    end type snake_type

    type apple_type
        integer :: x
        integer :: y
    end type apple_type

end module types_module
