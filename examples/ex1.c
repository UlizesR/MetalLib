#include <MKL.h>

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{

    MApplication app = {
        ._name = "example", 
        ._description = "example app description",
        ._version = "0.0.1",
        ._author = "Uli",
        ._icon = NULL,
    };

    printf("App Version: %s\n", app._version);

    MError err = MApplicationInit(&app, argc, argv);
    if (err == M_ERROR_INIT)
    {   
        MErrorPrint(err);
        return err;
    }

    MWindow *window = MMainAppWindow(800, 600, app._name);
    if (window == NULL)
    {
        MErrorPrint(M_ERROR_NULL_POINTER);
        return err;
    }

    MCreateContentView(window, M_COLOR_BLACK);

    MView *sview = MCreateSubView(window->contentView, 0, 0, 200, 200, M_COLOR_RED, MTrue, 0.0f);
    
    while (MWindowShouldClose(window))
    {
        MRunApplication();
    }

    MDestroyWindow(window);
    return 0;
}