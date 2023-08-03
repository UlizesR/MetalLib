#include "mac_window.h"
#include "mac_video.h"

int main() {
    
    int count;
    Video_Display* displays = getConnectedDisplays(&count);
    
    printDisplayInfo(displays, count);
    
    

    int window_width = displays[0].width;
    int window_height = displays[0].height;
    createWindow(window_width,window_height, "display 0 window 0");

    runWindow();
    freeDisplays(displays, count);
    return 0;
}
