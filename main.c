#include "src/MTLC.h"

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

    while(MTLCIsWindowOpen(window))
    {
        MTLCGetPollEvents();

        if (MTLCWasKeyPressed(MTLC_KEY_E) && MTLCWasKeyPressed(MTLC_KEY_Q))
        {
            printf("%d\n", i++);
        }
    }

    MTLCDestroyWindow(window);

    return 0;
}