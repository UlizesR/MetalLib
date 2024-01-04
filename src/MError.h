#ifndef _M_ERROR_H_
#define _M_ERROR_H_

#define M_SUCCESS 0
#define M_ERROR  1

typedef enum 
{
    M_ERROR_NONE = 0,
    M_ERROR_UNKNOWN = -1,
    M_ERROR_ALLOCATION = 2,
    M_ERROR_NULL_POINTER = 3,
    M_ERROR_INIT = 4,
    M_ERROR_TERMINATE = 5,
} MError;

// const char* MErrorMessage(MError error);

#endif // _M_ERROR_H_