#ifndef GULI_ERROR_H
#define GULI_ERROR_H

#include <stdio.h>
#include <assert.h>


typedef enum {
    GULI_ERROR_SUCCESS = 0,
    GULI_ERROR_FAILED = 1,
    GULI_ERROR_ALLOCATION_FAILED = 2,
    GULI_ERROR_ASSERTION_FAILED = 3,
} GULIResult;

typedef struct GuliError
{
    GULIResult result;
    const char* message;
} GuliError;

#define GULI_ERROR_MSG(type, msg) #type ": " msg
#define GULI_PRINT_ERROR(result, msg) fprintf(stderr, "ERROR [%d]: %s\n", (int)(result), (msg) ? (msg) : "(null)")
#define GULI_ERROR_RETURN(type, msg) { GULI_PRINT_ERROR(type, msg); return GULI_ERROR_FAILED; }
#define GULI_ERROR_RETURN_VOID(type, msg) { GULI_PRINT_ERROR(type, msg); return;}
#define GULI_ERROR_ASSERT(condition, type, msg) assert(condition) || GULI_ERROR_RETURN(type, msg)
#define GULI_ERROR_CHECK_N_RETURN(condition, type, msg) if (!condition) { GULI_PRINT_ERROR(type, msg); return GULI_ERROR_FAILED; }
#define GULI_ERROR_CHECK_N_RETURN_VOID(condition, type, msg) if (!condition) { GULI_PRINT_ERROR(type, msg); return; }

/* Fail, optionally set state->error, print, and return (for void functions) */
#define GULI_FAIL_RETURN(state, type, msg) \
    do { \
        if (state) GuliSetError(&(state)->error, type, msg); \
        GULI_PRINT_ERROR(type, msg); \
        return; \
    } while (0)

/* Fail with cleanup before return */
#define GULI_BAIL(state, type, msg, ...) \
    do { \
        if (state) GuliSetError(&(state)->error, type, msg); \
        GULI_PRINT_ERROR(type, msg); \
        __VA_ARGS__ \
        return; \
    } while (0)

void GuliSetError(GuliError* error, GULIResult result, const char* message);

#endif // GULI_ERROR_H
