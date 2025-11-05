#import "MKLInput.h"
#import "Keyboard.h"
#import "Mouse.h"
#import "../Core/MKLError.h"

#import <simd/vector.h>
#import <AppKit/AppKit.h>

void MKLPollEvents(void)
{
    @autoreleasepool {
        NSEvent *event;

        // Poll all available events (following GLFW pattern)
        while ((event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                           untilDate:[NSDate distantPast]
                                              inMode:NSDefaultRunLoopMode
                                             dequeue:YES]))
        {
            [NSApp sendEvent:event];
            [NSApp updateWindows];

            switch ([event type])
            {
                case NSEventTypeKeyDown:
                {
                    MKLSetKeyPressed(event.keyCode, true);
                    break;
                }
                case NSEventTypeKeyUp:
                {
                    MKLSetKeyPressed(event.keyCode, false);
                    break;
                }
                case NSEventTypeLeftMouseDown:
                {
                    MKLSetMouseButtonPressed(MouseCodeLeft, true);
                    break;
                }
                case NSEventTypeLeftMouseUp:
                {
                    MKLSetMouseButtonPressed(MouseCodeLeft, false);
                    break;
                }
                case NSEventTypeRightMouseDown:
                {
                    MKLSetMouseButtonPressed(MouseCodeRight, true);
                    break;
                }
                case NSEventTypeRightMouseUp:
                {
                    MKLSetMouseButtonPressed(MouseCodeRight, false);
                    break;
                }
                case NSEventTypeOtherMouseDown:
                {
                    MKLSetMouseButtonPressed((MouseCodes)event.buttonNumber, true);
                    break;
                }
                case NSEventTypeOtherMouseUp:
                {
                    MKLSetMouseButtonPressed((MouseCodes)event.buttonNumber, false);
                    break;
                }
                case NSEventTypeMouseMoved:
                case NSEventTypeLeftMouseDragged:
                case NSEventTypeRightMouseDragged:
                case NSEventTypeOtherMouseDragged:
                {
                    const NSPoint locationInWindow = [event locationInWindow];

                    // Update absolute position
                    MKLSetMousePosition((float)locationInWindow.x, (float)locationInWindow.y);

                    // Update delta
                    MKLSetMouseDelta((float)event.deltaX, (float)event.deltaY);
                    break;
                }
                case NSEventTypeScrollWheel:
                {
                    MKLScrollMouse((float)event.deltaY);
                    break;
                }
                default:
                    break;
            }
        }
    }
}

void MKLWaitEventsTimeout(const double timeout)
{
    @autoreleasepool {
        // Wait for event with timeout (following GLFW pattern)
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeout];
        NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                           untilDate:date
                                              inMode:NSDefaultRunLoopMode
                                             dequeue:YES];
        if (event)
        {
            [NSApp sendEvent:event];
        }

        // Poll remaining events
        MKLPollEvents();
    }
}

void MKLUpdateInputState(void)
{
    // Update state for both keyboard and mouse
    MKLUpdateKeyboardState();
    MKLUpdateMouseState();
}
