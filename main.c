// main.c
#include "mac.h"
#include <stdio.h>

int main() {
    int displayCount;
    Video_Display* displays = getConnectedDisplays(&displayCount);
    printf("Connected displays:\n");
    printDisplayInfo(displays, displayCount);

    int deviceCount;
    Video_Device* devices = getConnectedDevices(&deviceCount);
    printf("\nConnected devices:\n");
    printDeviceInfo(devices, deviceCount);

    MAC_Window window = createWindow(800, 600, "Hello World");
    printf("\nWindow created\n");

    runWindow();

    freeDisplays(displays, displayCount);
    releaseDevices();

    return 0;
}
