#include "Core/MKLError.h"

#include <Core/MKLCore.h>
#include <stdlib.h>

MKLAPI MKLError gError = {
    .type = MKL_ERROR_NONE,
    .message = NULL,
#ifdef __OBJC__
    ._error = nil,
#endif
};