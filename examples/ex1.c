#include "../src/MApp.h"
#include "../src/MError.h"
#include "../src/MWindow.h"

#include <stdio.h>

int main(int argc, char *argv[])
{
    MApplication app = {
        ._name = "example app",
        ._description = "example app description",
        ._version = "0.0.1",
        ._author = "Mehran",
        ._icon = NULL,
    };

    MError err = MApplicationInit(&app, argc, argv);
    if (err == M_ERROR_INIT)
    {   
        printf("Error Code %d\n", err);
        return err;
    }

    MWindow *window = MCreateMainWindow(800, 600, app._name);
    if (window == NULL)
    {
        printf("Error: The window could not be created.\n");
        return M_ERROR_INIT;
    }

    MRunApplication();

    MDestroyWindow(window);
    err = MApplicationTerminate();
    if (err != M_ERROR_NONE)
    {
        printf("Error: The application could not be terminated.\n");
        return err;
    }

    return 0;
}