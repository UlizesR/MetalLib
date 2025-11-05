#ifndef _MKL_ERROR_H_
#define _MKL_ERROR_H_

#include <stdio.h>
#include <stdlib.h>

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

/**
 * @brief Error codes for MKL operations.
 */
typedef enum MKLErrorCode {
    MKL_ERROR_NONE = 0,                         ///< No error
    MKL_ERROR_UNKNOWN = -1,                     ///< Unknown error
    MKL_ERROR_NULL_POINTER = 2,                 ///< Null pointer provided
    MKL_ERROR_FAILED_TO_ALLOCATE_MEMORY = 3,    ///< Memory allocation failed
    MKL_ERROR_FAILED_TO_OPEN_FILE = 4,          ///< File open operation failed
} MKLErrorCode;

/**
 * @brief Error structure containing error information.
 *
 * Note: NSError is not included in the struct when using ARC
 * to avoid retain cycle issues with global variables.
 */
typedef struct MKLError
{
    MKLErrorCode type;          ///< Error type/code
    const char *message;        ///< Human-readable error message
} MKLError;

/// Global error state
extern MKLError gError;

/**
 * @brief Check for NULL pointer and return with error handling.
 *
 * @param ptr Pointer to check for NULL
 * @param fObj Object to free if ptr is NULL (use NULL if no cleanup needed)
 * @param errCode MKLErrorCode to set on error
 * @param msg Error message string
 * @param ret Return value to use if ptr is NULL
 */
#define MKL_NULL_CHECK(ptr, fObj, errCode, msg, ret) \
    do { \
        if ((ptr) == NULL) { \
            fprintf(stderr, "MKL Error (%d) at %s:%d: %s\n", \
                    (int)(errCode), __FILE__, __LINE__, (msg)); \
            if ((fObj) != NULL) { \
                free(fObj); \
            } \
            gError.type = (errCode); \
            gError.message = (msg); \
            return (ret); \
        } \
    } while (0)

/**
 * @brief Check for NULL pointer in void functions.
 *
 * Similar to MKL_NULL_CHECK but for functions that return void.
 *
 * @param ptr Pointer to check for NULL
 * @param fObj Object to free if ptr is NULL (use NULL if no cleanup needed)
 * @param errCode MKLErrorCode to set on error
 * @param msg Error message string
 */
#define MKL_NULL_CHECK_VOID(ptr, fObj, errCode, msg) \
    do { \
        if ((ptr) == NULL) { \
            fprintf(stderr, "MKL Error (%d) at %s:%d: %s\n", \
                    (int)(errCode), __FILE__, __LINE__, (msg)); \
            if ((fObj) != NULL) { \
                free(fObj); \
            } \
            gError.type = (MKLErrorCode)(errCode); \
            gError.message = (msg); \
            return; \
        } \
    } while (0)

#endif // _MKL_ERROR_H_
