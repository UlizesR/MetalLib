#ifndef _MDL_ERROR_H_
#define _MDL_ERROR_H_

#define MDL_SUCESS 0
#define MDL_ERROR  1

typedef enum 
{
    MDL_ERROR_NONE = 0,
    MDL_ERROR_UNKNOWN = -1,
    MDL_ERROR_ALLOCATION = 2,
    MDL_ERROR_NULL_POINTER = 3,
    MDL_ERROR_INIT = 4,
} MError;

#define MDL_ERROR_CHECK(error, message) \
    if (error != MDL_ERROR_NONE) \
    { \
        printf("Error: %s\n", message); \
        return error; \
    }

#endif // _MDL_ERROR_H_