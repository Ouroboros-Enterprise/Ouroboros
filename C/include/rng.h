#ifndef RNG_H
#define RNG_H

#include "makros.h"

#include <stdlib.h>
#include <time.h>

static ALWAYS_INLINE int get_random_int(int min, int max)
{
    if (min >= max) // Prevents 0 Division
    {
        return min;
    }
    return min + rand() % (max - min + 1);
}

static ALWAYS_INLINE void rng_init(void)
{
    srand((unsigned int)time(NULL));
}

#endif // RNG_H
