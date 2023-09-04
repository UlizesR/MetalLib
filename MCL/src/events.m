// M_events.m
#import "MCL/events.h"

#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>

// Define an array to keep track of the state of each key
#define MAX_KEYS 256
static bool keys[MAX_KEYS] = {false};

int M_PollEvent(M_Event *event) {
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
    event->type = M_KEYBOARDEVENT;
    event->keycode = (M_KeyCode)[nsEvent keyCode];
    keys[event->keycode] = true;
    return 1;
    break;

  // Handle key up events
  case NSEventTypeKeyUp:
    event->type = M_KEYBOARDEVENT;
    event->keycode = (M_KeyCode)[nsEvent keyCode];
    keys[event->keycode] = false;
    return 1;
    break;
  case NSEventTypeLeftMouseDown:
    // Handle left mouse button down events
    event->type = M_MOUSEEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    event->button = M_BUTTON_LEFT;
    break;
  case NSEventTypeRightMouseDown:
    // Handle right mouse button down events
    event->type = M_MOUSEEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    event->button = M_BUTTON_RIGHT;
    break;
  case NSEventTypeOtherMouseDown:
    // Handle middle mouse button down events
    event->type = M_MOUSEEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    event->button = M_BUTTON_MIDDLE;
    break;
  case NSEventTypeScrollWheel:
    // Handle scroll wheel events
    event->type = M_SCROLLEVENT;
    event->x = [nsEvent locationInWindow].x;
    event->y = [nsEvent locationInWindow].y;
    if ([nsEvent deltaY] > 0) {
      event->direction = M_SCROLL_UP;
    } else if ([nsEvent deltaY] < 0) {
      event->direction = M_SCROLL_DOWN;
    } else {
      event->direction = M_NOSCROLL;
    }
    break;
  default:
    // For all other events, send them back to the application

    event->type = M_NOEVENT;
    break;
  }
  [NSApp sendEvent:nsEvent];
  return 1;
}
