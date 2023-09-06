// MCL_events.m
#import "MCL/events.h"

#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>

// Define an array to keep track of the state of each key
#define MAX_KEYS 256
static bool keys[MAX_KEYS] = {false};

int MCL_PollEvent(MCL_Event *event) {
  NSEvent *nsEvent = [NSApp nextEventMatchingMask:NSEventMaskAny
                                        untilDate:[NSDate distantPast]
                                           inMode:NSDefaultRunLoopMode
                                          dequeue:YES];

  if (nsEvent == nil) {
    return 0;
  }

  // Process the event
  switch ([nsEvent type]) {
  case NSEventTypeKeyDown:
    event->type = MCL_KEYBOARDEVENT;
    event->keycode = (MCL_KeyCode)[nsEvent keyCode];
    keys[event->keycode] = true;
    return 1;
    break;

  // Handle key up events
  case NSEventTypeKeyUp:
    event->type = MCL_KEYBOARDEVENT;
    event->keycode = (MCL_KeyCode)[nsEvent keyCode];
    keys[event->keycode] = false;
    return 1;
    break;
  case NSEventTypeLeftMouseDown:
    // Handle left mouse button down events
    event->type = MCL_MOUSEEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    event->button = MCL_BUTTON_LEFT;
    break;
  case NSEventTypeRightMouseDown:
    // Handle right mouse button down events
    event->type = MCL_MOUSEEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    event->button = MCL_BUTTON_RIGHT;
    break;
  case NSEventTypeOtherMouseDown:
    // Handle middle mouse button down events
    event->type = MCL_MOUSEEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    event->button = MCL_BUTTON_MIDDLE;
    break;
  case NSEventTypeScrollWheel:
    // Handle scroll wheel events
    event->type = MCL_SCROLLEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    if ([nsEvent deltaY] > 0) {
      event->direction = MCL_SCROLL_UP;
    } else if ([nsEvent deltaY] < 0) {
      event->direction = MCL_SCROLL_DOWN;
    } else {
      event->direction = MCL_NOSCROLL;
    }
    break;
  default:
    // For all other events, send them back to the application

    event->type = MCL_NOEVENT;
    break;
  }
  [NSApp sendEvent:nsEvent];
  return 1;
}
