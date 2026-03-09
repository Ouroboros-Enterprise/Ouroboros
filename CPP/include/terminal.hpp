#pragma once

#include "makros.hpp"

#include <iostream>
#include <ostream>

ALWAYS_INLINE void gotoXY(int x, int y) noexcept
{
    std::cout << "\033[" << y << ";" << x << "H" << std::flush;
}
