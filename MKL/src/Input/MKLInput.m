#import "MKLInput.h"
#import "Keyboard.h"
#import "Mouse.h"

#import "../Core/MKLError.h"


#import <Cocoa/Cocoa.h>

void MKLGetPollEvents(void)
{
    // Poll for application events
    NSEvent *appEvent = [NSApp nextEventMatchingMask:NSEventMaskAny
                                           untilDate:[NSDate distantPast]
                                              inMode:NSDefaultRunLoopMode
                                             dequeue:YES];

    [NSApp sendEvent:appEvent];
    [NSApp updateWindows];

    switch ([appEvent type])
    {
        case NSEventTypeKeyDown:
        {
            MKLSetKeyPressed(appEvent.keyCode, YES);
            break;
        }
        case NSEventTypeKeyUp:
            MKLSetKeyPressed(appEvent.keyCode, NO);
            break;
        case NSEventTypeLeftMouseDown:
        case NSEventTypeRightMouseDown:
        case NSEventTypeOtherMouseDown:
        {
            MKLSetMouseButtonPressed(appEvent.buttonNumber, YES);
            break;
        }
        case NSEventTypeLeftMouseUp:
        case NSEventTypeRightMouseUp:
        case NSEventTypeOtherMouseUp:
            MKLSetMouseButtonPressed(appEvent.buttonNumber, NO);
            break;
        default:
            break;
    }
}

bool MKLWasKeyPressed(int key)
{
    BOOL wasKeyPressed = MKLIsKeyPressed(key);
    if (wasKeyPressed)
    {
        MKLSetKeyPressed(key, NO);
    }
    return wasKeyPressed;
}

bool MKLWasMouseButtonPressed(int button)
{
    BOOL wasMouseButtonPressed = MKLIsMouseButtonPressed(button);
    if (wasMouseButtonPressed)
    {
        MKLSetMouseButtonPressed(button, NO);
    }
    return wasMouseButtonPressed;
}