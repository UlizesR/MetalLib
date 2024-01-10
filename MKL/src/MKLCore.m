#import "MKLCore.h"
#import "Input/Keyboard.h"
#import "Input/Mouse.h"

#import <Cocoa/Cocoa.h>


void MKLGetPollEvents(void)
{
    NSEvent *nsevent = [NSApp nextEventMatchingMask:NSEventMaskAny
                                   untilDate:[NSDate distantFuture] // This allows for the app to only poll for events when it needs to
                                   inMode:NSDefaultRunLoopMode
                                   dequeue:YES];

    if (!nsevent) {
        return;
    }

    switch ([nsevent type])
    {
        case NSEventTypeKeyDown:
            MKLSetKeyPressed(nsevent.keyCode, YES);
            break;
        case NSEventTypeKeyUp:
            MKLSetKeyPressed(nsevent.keyCode, NO);
            break;
        case NSEventTypeLeftMouseDown:
            MKLSetMouseButtonPressed(nsevent.buttonNumber, YES);
            break;
        case NSEventTypeLeftMouseUp:
            MKLSetMouseButtonPressed(nsevent.buttonNumber, NO);
            break;
        case NSEventTypeRightMouseDown:
            MKLSetMouseButtonPressed(nsevent.buttonNumber, YES);
            break;
        case NSEventTypeRightMouseUp:
            MKLSetMouseButtonPressed(nsevent.buttonNumber, NO);
            break;
        case NSEventTypeOtherMouseDown:
            MKLSetMouseButtonPressed(nsevent.buttonNumber, YES);
            break;
        case NSEventTypeOtherMouseUp:
            MKLSetMouseButtonPressed(nsevent.buttonNumber, NO);
            break;
        default:
            break;
    }

    [NSApp sendEvent:nsevent];
    [NSApp updateWindows];
}
