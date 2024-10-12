#ifndef _MKL_KEYBOARD_H_
#define _MKL_KEYBOARD_H_

#include "KeyCodes.h"
#include <stdbool.h>

#include "../Core/MKLCore.h"

void MKLSetKeyPressed(unsigned short keyCode, bool isOn);

MKLAPI bool MKLIsKeyPressed(unsigned short keyCode);

#endif // _MKL_KEYBOARD_H_