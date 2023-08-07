#ifndef maca_h_
#define maca_h_

#ifndef __APPLE__
#error "This file is only for Mac OS X"
#endif

#include "mac_window.h"
#include "mac_video.h"
#include "mac_init.h"
#include "mac_events.h"
#include "mac_error.h"
#include "mac_pixels.h"
#include "mac_view.h"
#include "mac_button.h"
#include "mac_internals.h"
#include "mac_slider.h"
#include "mac_shapes.h"

void MAC_Quit();

#endif // maca_h_
