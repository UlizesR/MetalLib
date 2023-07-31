#include "mac_window.h"

int main(int argc, char *argv[])
{
    Window* window = createWindow(800, 600, "Hello World");
    runWindow();

    return 0;
}