#include "mac.h"
#include "mac_delegate.h"

void MAC_Quit()
{
    terminateDelegate();
}

/*
    The Init function from mac_init.h
    Iniitalizes the delegate
    
    returns 0 if successful
*/
int MAC_Init()
{
    initDelegate();

    return 0;
}