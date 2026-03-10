#ifndef MAKRO_H
#define MAKRO_H

#ifdef _MSC_VER
#define ALWAYS_INLINE __forceinline
#else
#define ALWAYS_INLINE __attribute__((always_inline)) inline
#endif

#endif // MAKRO_H
