#ifndef MAC_H_
#define MAC_H_

#ifndef __APPLE__
#error "This file is only for Mac OS X"
#endif

#include "../../include/mac_window.h"
#include "../../include/mac_video.h"
#include "../../include/mac_init.h"
#include "../../include/mac_events.h"
#include "../../include/mac_error.h"
#include "../../include/mac_pixels.h"
#include "../../include/mac_view.h"

void ignoreApps();
void MAC_Quit();

#endif // MAC_H_