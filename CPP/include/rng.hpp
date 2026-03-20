#pragma once

#include "makros.hpp"

#ifndef _WIN32
#include <ctime>
#endif
#include <random>

class RandomNumberGenerator
{
    mutable std::random_device rd;

public:
    [[nodiscard]] ALWAYS_INLINE int generateRandomNumber(int min,
                                                         int max) const noexcept
    {
#ifdef _WIN32
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> distr(min, max);

        return distr(gen);
#else
        if (min >= max) [[unlikely]]
        {
            return min;
        }
        return min + rand() % (max - min + 1);
#endif
    }

#ifndef _WIN32
    static ALWAYS_INLINE void rngInit()
    {
        srand((unsigned long)time(NULL));
    }
#endif
};
