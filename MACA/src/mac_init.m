#include "MACA/mac_delegate.h"
#include "MACA/mac_init.h"
#include <stdio.h>

int M_Init(UInt32 flags)
{
    M_Delegate *delegate = initDelegate();
    if (delegate == nil) {
        return -1; // Consistent with the header file
    }

    return 0;
}

void M_Quit()
{
    printf("Terminating App");
    terminateDelegate();
}