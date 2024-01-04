#include "../src/MDL.h"

#include <_types/_uint32_t.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    MApplication app = {
        ._name = "example app",
        ._description = "example app description",
        ._version = "0.0.1",
        ._author = "Uli",
        ._icon = NULL,
    };

    printf("App Version: %s\n", app._version);

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

    MCreateContentView(window, M_COLOR_BLACK);
    MSetWindowHints(window, MWINDOW_FLAG_RESIZABLE);

    MView *sview = MCreateSubView(window->contentView, 100, 100, 200, 300, M_COLOR_RED, MTrue, 10.0f);

    MRunApplication();

    MDestroyView(sview);
    MDestroyWindow(window);
    err = MApplicationTerminate();
    if (err != M_ERROR_NONE)
    {
        printf("Error: The application could not be terminated.\n");
        return err;
    }

    return 0;
}