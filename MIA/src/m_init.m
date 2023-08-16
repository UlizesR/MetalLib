#include "MIA/m_delegate.h"
#include "MIA/m_init.h"
#include <stdio.h>

int M_Init(UInt32 flags)
{
    M_Delegate *delegate = initDelegate();
    if (delegate == nil) {
        return -1; 
    }

    return 0;
}

void M_Quit()
{
    printf("Terminating App\n");
    terminateDelegate();
}