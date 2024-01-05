#include "MError.h"

#include <stdio.h>

const char *MErrorMessage(MError error) 
{
    switch (error) 
    {
        case M_ERROR_NONE:
            return "No error";
        case M_ERROR_UNKNOWN:
            return "Unknown error";
        case M_ERROR_ALLOCATION:
            return "Allocation error";
        case M_ERROR_NULL_POINTER:
            return "Null pointer error";
        case M_ERROR_INIT:
            return "Initialization error";
        case M_ERROR_TERMINATE:
            return "Termination error";
    }
}

void MErrorPrint(MError error) 
{
    printf("Error Code: %d \t Msg: %s\n", error, MErrorMessage(error));
}