#import "MEvent.h"

void MGetPollEvents(MEvent* event)
{
    event->_event =  [NSApp nextEventMatchingMask:NSEventMaskAny
                                   untilDate:[NSDate distantPast]
                                   inMode:NSDefaultRunLoopMode
                                   dequeue:YES];
        if (event->_event == nil) 
        {
            return;
        }

        switch ([event->_event type])
        {
            case NSEventTypeKeyDown:
                event->type = M_KEYBOARD_EVENT;
                event->keyboardEvent.type = M_KEY_DOWN;
                event->keyboardEvent.keyCode = [event->_event keyCode];
                break;
            case NSEventTypeKeyUp:
                event->type = M_KEYBOARD_EVENT;
                event->keyboardEvent.type = M_KEY_UP;
                event->keyboardEvent.keyCode = [event->_event keyCode];
                break;
            case NSEventTypeLeftMouseDown:
                event->type = M_MOUSE_EVENT;
                event->mouseEvent.type = M_MOUSE_DOWN;
                event->mouseEvent.x = [event->_event locationInWindow].x;
                event->mouseEvent.y = [event->_event locationInWindow].y;
                break;
            case NSEventTypeLeftMouseUp:
                event->type = M_MOUSE_EVENT;
                event->mouseEvent.type = M_MOUSE_UP;
                event->mouseEvent.x = [event->_event locationInWindow].x;
                event->mouseEvent.y = [event->_event locationInWindow].y;
                break;
            // case NSEventTypeRightMouseDown:
            //     event->type = M_MOUSE_EVENT;
            //     event->mouseEvent.type = M_MOUSE_DOWN;
            //     event->mouseEvent.x = [event->_event locationInWindow].x;
            //     event->mouseEvent.y = [event->_event locationInWindow].y;
            //     break;
            // case NSEventTypeRightMouseUp:
            //     event->type = M_MOUSE_EVENT;
            //     event->mouseEvent.type = M_MOUSE_UP;
            //     event->mouseEvent.x = [event->_event locationInWindow].x;
            //     event->mouseEvent.y = [event->_event locationInWindow].y;
            //     break;
            // case NSEventTypeMouseMoved:
            //     event->type = M_MOUSE_EVENT;
            //     event->mouseEvent.type = M_MOUSE_MOVE;
            //     event->mouseEvent.x = [event->_event locationInWindow].x;
            //     event->mouseEvent.y = [event->_event locationInWindow].y;
            //     event->mouseEvent.deltaX = [event->_event deltaX];
            //     event->mouseEvent.deltaY = [event->_event deltaY];
            //     break;
            default:
                event->type = M_NO_EVENT;
                break;
        }

        [NSApp sendEvent:event->_event];
        // [NSApp updateWindows];
}

// MKeyCode MGetKeyCode(MEvent* event)
// {
//     if (event->type != M_KEYBOARD_EVENT)
//     {
//         NSLog(@"MGetKeyCode: event is not a keyboard event");
        
//     }
// }