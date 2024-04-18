#ifndef _MTLC_ERROR_H_
#define _MTLC_ERROR_H_

#include <stdio.h>
#include <stdlib.h>

typedef enum {
    MTLC_NO_ERROR = 0,
    MTLC_ERROR = 1,
    MTLC_ERROR_PLATFORM = 2,
    MTLC_ERROR_DEVICE = 3,
    MTLC_ERROR_ALLOC = 4,
    MTLC_ERROR_FILE = 5,
    MTLC_ERROR_INVALID_INPUT = 6,
    MTLC_ERROR_NULL = 7,
    MTLC_ERROR_NS_ALLOC = 8,  // Update this value
    MTLC_ERROR_NS_DELEGATE = 9
} MTLCErrorType;

#define MTLC_ERROR_COUNT 10

static const char* MTLCErrorMessages[MTLC_ERROR_COUNT] = {
    "No error",
    "Unknown error",
    "Platform error",
    "Device error",
    "Allocation error",
    "File error",
    "Invalid input error",
    "Null error",
    "Cocoa allocation error",
    "Cocoa delegate error"
};

#define MTLC_GET_ERROR_MESSAGE(type) (MTLCErrorMessages[type])

typedef struct {
    MTLCErrorType type;
    const char* message;
} MTLCError;

void MTLCSetError(MTLCError *error, MTLCErrorType type, const char* message);

void MTLCPrintError(MTLCError *error);

#endif // _MTLC_ERROR_H_