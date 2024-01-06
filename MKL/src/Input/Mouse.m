#import "Mouse.h"


static const NSInteger MOUSE_BUTTON_COUNT = 12;
static BOOL mouseButtonList[MOUSE_BUTTON_COUNT];

static vector_float2 overallMousePosition = {0, 0};
static vector_float2 mousePositionDelta = {0, 0};

static float scrollWheelPosition = 0;
static float lastWheelPosition = 0.0;
static float scrollWheelChange = 0.0;

@implementation Mouse

+ (void)setMouseButtonPressed:(NSInteger)button isOn:(BOOL)isOn 
{
    mouseButtonList[button] = isOn;
}

+ (BOOL)isMouseButtonPressed:(MouseCodes)button 
{
    return mouseButtonList[button];
}

+ (void)setOverallMousePosition:(vector_float2)position 
{
    overallMousePosition = position;
}

+ (void)setMousePositionChangeWithOverallPosition:(vector_float2)overallPosition deltaPosition:(vector_float2)deltaPosition 
{
    overallMousePosition = overallPosition;
    mousePositionDelta += deltaPosition;
}

+ (void)scrollMouse:(float)deltaY 
{
    scrollWheelPosition += deltaY;
    scrollWheelChange += deltaY;
}

+ (vector_float2)getMouseWindowPosition 
{
    return overallMousePosition;
}

+ (float)getDWheel 
{
    float position = scrollWheelChange;
    scrollWheelChange = 0;
    return position;
}

+ (float)getDY 
{
    float result = mousePositionDelta.y;
    mousePositionDelta.y = 0;
    return result;
}

+ (float)getDX 
{
    float result = mousePositionDelta.x;
    mousePositionDelta.x = 0;
    return result;
}

+ (vector_float2)getMouseViewportPosition:(vector_float2)viewportSize 
{
    float x = (overallMousePosition.x - viewportSize.x * 0.5) / (viewportSize.x * 0.5);
    float y = (overallMousePosition.y - viewportSize.y * 0.5) / (viewportSize.y * 0.5);
    return (vector_float2){x, y};
}

@end