#ifndef _MKL_DEFS_H_
#define _MKL_DEFS_H_

#include "MKLError.h"

#define MKLAPI __attribute__((visibility("default")))

MKLAPI void MKLGetPollEvents(void);

#endif // _MKL_DEFS_H_