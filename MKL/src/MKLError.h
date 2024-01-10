#ifndef _MKL_ERROR_H_
#define _MKL_ERROR_H_

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

typedef enum MKLErrorCode {
    MKL_ERROR_NONE = 0,
    MKL_ERROR_UNKNOWN = -1,
    MKL_ERROR_NULL_POINTER = 2,
    MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY = 3,
    MKL_ERROR_FAILED_TO_OPEN_FILE = 4,
} MKLErrorCode;

typedef struct MKLError
{
    MKLErrorCode type;
    const char *message;
#ifdef __OBJC__
    NSError *_error;
#endif
} MKLError;

extern MKLError gError;

/*!
    * @brief Check for NULL pointer and return
    * @param ptr pointer to check
    * @param fObj free passed object if not NULL
    * @param type MKLErrorCode
    * @param msg error message
    * @param ret return value of the function
*/
#define MKL_NULL_CHECK(ptr, fObj, errCode, msg, ret) \
    if (ptr == NULL) { \
        fprintf(stderr, "MKL Error (%d): File %s, Line %d: %s\n", errCode, __FILE__, __LINE__, msg); \
        if (fObj != NULL) { \
            free(fObj); \
        } \
        gError.type = errCode; \
        gError.message = msg; \
        return ret; \
    }

#define MKL_NULL_CHECK_VOID(ptr, fObj, errCode, msg) \
    if (ptr == NULL) { \
        fprintf(stderr, "MKL Error (%d): File %s, Line %d: %s\n", errCode, __FILE__, __LINE__, msg); \
        if (fObj != NULL) { \
            free(fObj); \
        } \
        gError.type = (MKLErrorCode)errCode; \
        gError.message = msg; \
        return; \
    }

#endif // _MKL_ERROR_H_