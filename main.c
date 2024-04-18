#include "src/Include/MTLC.h"
#include <src/Include/MTLCEvents.h>
#include <src/Include/MTLCTimer.h>

int main(void)
{
    MTLCError error;
    MTLCWindow *window = MTLCCreateWindow("MTLC Window", 800, 600, &error);
    if (window == NULL)
    {
        MTLCPrintError(&error);
        return 1;
    }

    int i = 0;
    unsigned int ticks = 0;
    int fps = 60;

    while(MTLCIsWindowOpen(window))
    {
        MTLCGetPollEvents();

        if (MTLCWasKeyPressed(MTLC_KEY_Q))
        {
            break;
        }

        ticks = MTLCGetTicks() / 1000;
        printf("Seconds: %d s\n", ticks);
        fps = MTLCGetFPS();
        printf("FPS: %d\n", fps);
    }

    MTLCDestroyWindow(window);

    return 0;
}