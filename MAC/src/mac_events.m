// mac_events.m
#import "MAC/mac_events.h"
#import <Cocoa/Cocoa.h>

int MAC_PollEvent(MAC_Event* event) {
    NSEvent* nsEvent = [NSApp nextEventMatchingMask:NSEventMaskAny
                                          untilDate:[NSDate distantPast]
                                             inMode:NSDefaultRunLoopMode
                                            dequeue:YES];
    if (nsEvent == nil) {
        return 0;
    }

    // Process the event
    switch ([nsEvent type]) {
        case NSEventTypeKeyDown:
            // Handle key down events
            event->type = MAC_KEYBOARDEVENT;
            event->keycode = (MAC_KeyCode)[nsEvent keyCode];
            break;
        case NSEventTypeLeftMouseDown:
            // Handle left mouse button down events
            event->type = MAC_MOUSEEVENT;
            event->x = [nsEvent locationInWindow].x;
            event->y = [nsEvent locationInWindow].y;
            event->button = MAC_BUTTON_LEFT;
            break;
        case NSEventTypeRightMouseDown:
            // Handle right mouse button down events
            event->type = MAC_MOUSEEVENT;
            event->x = [nsEvent locationInWindow].x;
            event->y = [nsEvent locationInWindow].y;
            event->button = MAC_BUTTON_RIGHT;
            break;
        case NSEventTypeOtherMouseDown:
            // Handle middle mouse button down events
            event->type = MAC_MOUSEEVENT;
            event->x = [nsEvent locationInWindow].x;
            event->y = [nsEvent locationInWindow].y;
            event->button = MAC_BUTTON_MIDDLE;
            break;
        case NSEventTypeScrollWheel:
            // Handle scroll wheel events
            event->type = MAC_SCROLLEVENT;
            event->x = [nsEvent locationInWindow].x;
            event->y = [nsEvent locationInWindow].y;
            if ([nsEvent deltaY] > 0) {
                event->direction = MAC_SCROLL_UP;
            } else if ([nsEvent deltaY] < 0) {
                event->direction = MAC_SCROLL_DOWN;
            } else {
                event->direction = MAC_NOSCROLL;
            }
            break;
        default:
            event->type = MAC_NOEVENT;
            break;
    }

    [NSApp sendEvent:nsEvent];
    return 1;
}
