#ifndef GULI_HASH_H
#define GULI_HASH_H

#include <stdint.h>

/** FNV-1a hash for string keys. Shared by Metal/OpenGL uniform lookup. */
static inline uint32_t GuliHashFNV1a(const char* name)
{
    uint32_t h = 2166136261u;
    for (; *name; name++)
        h = (h ^ (unsigned char)*name) * 16777619u;
    return h;
}

#endif // GULI_HASH_H
