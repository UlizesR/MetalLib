#ifndef _MKL_INPUT_H_
#define _MKL_INPUT_H_

#include "../Core/MKLCore.h"

MKLAPI void MKLGetPollEvents(void);

MKLAPI bool MKLWasKeyPressed(int key);

MKLAPI bool MKLWasMouseButtonPressed(int button);

#endif /* _MKL_INPUT_H_ */