package include

import "math/rand/v2"

func GetRandInt(min, max int) int {
	return rand.IntN(max - min + 1) + min
}