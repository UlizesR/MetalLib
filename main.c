// main.c
#include "mac.h"
#include <stdio.h>

int main() {
    if (MAC_Init(0) != 0) {
        printf("Failed to initialize\n");
        return 1;
    }

    MAC_Window* window = createWindow(800, 600, "Test Window");
    if (window == NULL) {
        printf("Failed to create window\n");
        return 1;
    }

    ignoreApps();

    MAC_Event event;
    bool running = true;
    while (running) {
        while (MAC_PollEvent(&event)) {
            switch (event.type) {
                case MAC_KEYBOARDEVENT:
                    printf("Key pressed: %d\n", event.keycode);
                    if (event.keycode == MAC_KEY_ESCAPE) {
                        running = false;
                    }
                    break;
                case MAC_MOUSEEVENT:
                    printf("Mouse button pressed: %d at (%d, %d)\n", event.button, event.x, event.y);
                    break;
                default:
                    break;
            }
        }
        // Check if the window is still open
        if (!isWindowOpen(window)) {
            running = false;
        }
    }

    destroyWindow(window);
    MAC_Quit();

    return 0;
}
