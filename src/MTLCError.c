#include "Include/MTLCError.h"

void MTLCSetError(MTLCError *error, MTLCErrorType type, const char *message) 
{
    static char errMsg[256];
    snprintf(errMsg, sizeof(errMsg), "%s: %s", MTLC_GET_ERROR_MESSAGE(type), message);
    error->type = type;
    error->message = message;
}

void MTLCPrintError(MTLCError *error)
{
    fprintf(stderr, "Error: %s\n", error->message);}