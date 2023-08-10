#include "MACA/mac_delegate.h"
#include "MACA/mac_init.h"
#include <stdio.h>

int MAC_Init(UInt32 flags)
{
    Mac_Delegate *delegate = initDelegate();
    if (delegate == nil) {
        return -1; // Consistent with the header file
    }

    return 0;
}

void MAC_Quit()
{
    printf("Terminating App");
    terminateDelegate();
}