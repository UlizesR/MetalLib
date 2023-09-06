#ifndef _mcl_errors_h_
#define _mcl_errors_h_

#include "defs.h"
#include <signal.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MCL_SUCCESS 0
#define MCL_FAILURE 1

#define MCL_ERROR_LOCATION(ERROR, FORMAT, ...)                                       \
{                                                                                \
    if (ERROR) {                                                                 \
        fprintf(stderr, "%s -> %s -> %i -> Error(%i):\n\t" FORMAT "\n",          \
              __FILE_NAME__, __FUNCTION__, __LINE__, ERROR, ##__VA_ARGS__);      \
    }                                                                            \
}

typedef enum {
  MCL_ERROR_NONE = 0,                   // No error
  MCL_ERROR_UNKNOWN = 1,                // Unknown error
  // Delegate errors    
  MCL_ERROR_DELEGATE_INIT = 2,          // Error initializing the delegate
  MCL_ERROR_DELEGATE_RUN = 3,           // Error running the delegate
  MCL_ERROR_DELEGATE_TERMINATE = 4,     // Error terminating the delegate
  MCL_ERROR_DELEGATE_NULL = 5,          // The delegate is null
} MCL_Error_Type;

typedef struct MCL_Error {
    MCL_Error_Type type;                // The type of error
    const char *message;                // The message of the error
} MCL_Error;



void MCL_Create_Error_LogFile(const char *path);
void MCL_Log_Error(MCL_Error_Type type, const char *message);

#ifdef __cplusplus
}
#endif

#endif // _mcl_errors_h_