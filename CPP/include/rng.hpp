#pragma once

#include "makros.hpp"

#include <random>

class RandomNumberGenerator
{
    mutable std::random_device rd;

public:
    [[nodiscard]] ALWAYS_INLINE int generateRandomNumber(int min,
                                                         int max) const noexcept
    {
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> distr(min, max);

        return distr(gen);
    }
};
