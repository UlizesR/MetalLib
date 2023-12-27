#include "../src/MWindow.h"
#include "../src/MApp.h"

#include <stdio.h>

int main(int argc, char *argv[])
{
    MAppInstance app = {
        .info = {
            ._name = "MApp Example",
            ._version = "0.0.1",
            ._author = "MApp",
            ._description = "MApp Example",
            ._url = ""
        },
        .main_window = NULL,
    };

    if (MAppInit(&app, argc, argv))
    {
        printf("Failed to initialize MApp\n");
        return 1;
    }

    app.main_window = MCreateMainWindow(800, 600, "MApp Example");
    if (!app.main_window)
    {
        printf("Failed to create main window\n");
        return 1;
    }

    MShowWindow(app.main_window);

    MDestroyWindow(app.main_window);
    return MTerminateApp(&app);
}