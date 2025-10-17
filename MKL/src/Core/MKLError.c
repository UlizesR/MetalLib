#include "MKLError.h"

#include "MKLCore.h"
#include <stdlib.h>

// Global error state - note: NSError must be handled separately due to ARC
MKLAPI MKLError gError = {
    .type = MKL_ERROR_NONE,
    .message = NULL,
};
