#import "Mouse.h"


static const int MOUSE_BUTTON_COUNT = 12;
static bool mouseButtonList[MOUSE_BUTTON_COUNT];

static vector_float2 overallMousePosition = {0, 0};
static vector_float2 mousePositionDelta = {0, 0};

static float scrollWheelPosition = 0;
static float lastWheelPosition = 0.0;
static float scrollWheelChange = 0.0;

void MKLSetMouseButtonPressed(MouseCodes button, bool isOn)
{
    mouseButtonList[button] = isOn;
}

bool MKLIsMouseButtonPressed(MouseCodes button)
{
    return mouseButtonList[button];
}

void MKLSetOverallMousePosition(float x, float y)
{
    overallMousePosition.x = x;
    overallMousePosition.y = y;
}

void MKLSetMousePositionChangeWithOverallPosition(float x, float y)
{
    mousePositionDelta.x += x;
    mousePositionDelta.y += y;
}

void MKLScrollMouse(float deltaY)
{
    scrollWheelPosition += deltaY;
    scrollWheelChange += deltaY;
}

float MKLGetMouseDWheel()
{
    float position = scrollWheelChange;
    scrollWheelChange = 0;
    return position;
}

float MKLGetMouseDY()
{
    float result = mousePositionDelta.y;
    mousePositionDelta.y = 0;
    return result;
}

float MKLGetMouseDX()
{
    float result = mousePositionDelta.x;
    mousePositionDelta.x = 0;
    return result;
}

vector_float2 MKLGetMouseViewportPosition(float viewportWidth, float viewportHeight)
{
    float x = (overallMousePosition.x - viewportWidth * 0.5) / (viewportWidth * 0.5);
    float y = (overallMousePosition.y - viewportHeight * 0.5) / (viewportHeight * 0.5);
    return (vector_float2){x, y};
}

vector_float2 MKLGetMouseWindowPosition()
{
    return overallMousePosition;
}