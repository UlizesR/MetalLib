#ifndef MAC_H_
#define MAC_H_

#ifndef __APPLE__
#error "This file is only for Mac OS X"
#endif

#include "mac_window.h"
#include "mac_video.h"
#include "mac_init.h"

void MAC_Quit();

#endif // MAC_H_