#import "MTLCEvents.h"
#import <Cocoa/Cocoa.h>

// Constants
static const int MOUSE_BUTTON_COUNT = 12;
static const unsigned short KEY_COUNT = 256;

// Mouse related variables
static bool mouseButtonList[MOUSE_BUTTON_COUNT];
static vector_float2 overallMousePosition = {0, 0};
static vector_float2 mousePositionDelta = {0, 0};
static float scrollWheelPosition = 0;
static float lastWheelPosition = 0.0;
static float scrollWheelChange = 0.0;

// Keyboard related variables
static bool keys[KEY_COUNT];

// Mouse button functions
void MTLCSetMouseButtonPressed(MouseCodes button, bool isOn)
{
    mouseButtonList[button] = isOn;
}

bool MTLCIsMouseButtonPressed(MouseCodes button)
{
    return mouseButtonList[button];
}

bool MTLCWasMouseButtonPressed(int button)
{
    BOOL wasMouseButtonPressed = MTLCIsMouseButtonPressed(button);
    if (wasMouseButtonPressed)
    {
        MTLCSetMouseButtonPressed(button, NO);
    }
    return wasMouseButtonPressed;
}

bool MTLCIsMouseButtonHeldDown(int button)
{
    return  MTLCIsMouseButtonPressed(button);
}

// Mouse position functions
void MTLCSetOverallMousePosition(float x, float y)
{
    overallMousePosition.x = x;
    overallMousePosition.y = y;
}

void MTLCSetMousePositionChangeWithOverallPosition(vector_float2 oPos, vector_float2 dPos)
{
    overallMousePosition = oPos;
    mousePositionDelta = dPos;
}

vector_float2 MTLCGetMouseWindowPosition()
{
    return overallMousePosition;
}

vector_float2 MTLCGetMouseViewportPosition(float viewportWidth, float viewportHeight)
{
    float x = (overallMousePosition.x - viewportWidth * 0.5) / (viewportWidth * 0.5);
    float y = (overallMousePosition.y - viewportHeight * 0.5) / (viewportHeight * 0.5);
    return (vector_float2){x, y};
}

// Mouse scroll functions
void MTLCScrollMouse(float deltaY)
{
    scrollWheelPosition += deltaY;
    scrollWheelChange += deltaY;
}

float MTLCGetMouseDWheel()
{
    float position = scrollWheelChange;
    scrollWheelChange = 0;
    return position;
}

// Mouse delta functions
float MTLCGetMouseDY()
{
    float result = mousePositionDelta.y;
    mousePositionDelta.y = 0;
    return result;
}

float MTLCGetMouseDX()
{
    float result = mousePositionDelta.x;
    mousePositionDelta.x = 0;
    return result;
}

// Keyboard functions
void MTLCSetKeyPressed(unsigned short keyCode, bool isOn)
{
    keys[keyCode] = isOn;
}

bool MTLCIsKeyPressed(unsigned short keyCode)
{
    return keys[keyCode];
}

bool MTLCWasKeyPressed(int key)
{
    BOOL wasKeyPressed = MTLCIsKeyPressed(key);
    if (wasKeyPressed)
    {
        MTLCSetKeyPressed(key, NO);
    }
    return wasKeyPressed;
}

// Event polling function
void MTLCGetPollEvents(void)
{
   @autoreleasepool { // Poll for application events
    NSEvent *appEvent;
    while((appEvent = [NSApp nextEventMatchingMask:NSEventMaskAny
                                           untilDate:[NSDate distantPast]
                                              inMode:NSDefaultRunLoopMode
                                             dequeue:YES]))
    {
        [NSApp sendEvent:appEvent];
        [NSApp updateWindows];

        switch ([appEvent type])
        {
            case NSEventTypeKeyDown:
            {
                MTLCSetKeyPressed(appEvent.keyCode, YES);
                break;
            }
            case NSEventTypeKeyUp:
                MTLCSetKeyPressed(appEvent.keyCode, NO);
                break;
            case NSEventTypeLeftMouseDown:
            case NSEventTypeRightMouseDown:
            case NSEventTypeOtherMouseDown:
            {
                MTLCSetMouseButtonPressed(appEvent.buttonNumber, YES);
                break;
            }
            case NSEventTypeLeftMouseUp:
            case NSEventTypeRightMouseUp:
            case NSEventTypeOtherMouseUp:
            {
                MTLCSetMouseButtonPressed(appEvent.buttonNumber, NO);
                break;
            }
            case NSEventTypeMouseMoved:
            {
                NSPoint locationInWindow = [appEvent locationInWindow];
                vector_float2 overallLocation = {locationInWindow.x, locationInWindow.y};
                vector_float2 deltaLocation = {appEvent.deltaX, appEvent.deltaY};
                MTLCSetMousePositionChangeWithOverallPosition(overallLocation, deltaLocation);
                break;
            }
            default:
                break;
        }
    }}
}