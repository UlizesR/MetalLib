#include "Core/guli_error.h"

void GuliSetError(GuliError* error, GULIResult result, const char* message)
{
    error->result = result;
    error->message = message;
}