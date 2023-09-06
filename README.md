# MCL API (macOS iOS applications)

## About

A C wrapper api that acts something similar to the Window's API (window.h)
It's meant to allow macOS development using C/C++ instead of just using Objectice-C or Swift.
For those of us who like to use C and C++ that is.

## Tools and Technologies

#### Languages:

* C
* Objective-C

#### Frameworks

* Cocoa

## How to use the MCL Library

Getting an app window going

1. Include the MCL library
```C++
#include <MCL/MCL.h>
```

2. Initilized the app state
   
```C++
MCL_App app = {
    .app_info = {
        .name = "Example App",
        .version = MCL_APP_VERSION(1, 0, 0),
        .author = "me",
        .description = "An example app",
    },
    .app_window = NULL,
    .device = NULL,
};
```

3. Initialize the App itself

```C++
if(MCL_InitApp(&app) != 0)
{
    fprintf(stderr, "Failed to initialize app\n");
    return 1;
}
```

5. Create the app's main window
   
```C++
MCL_AppWindow(&app, WINDOW_WIDTH, WINDOW_HEIGHT, app.app_info.name);
```

6. Add the run loop for the app

```C++
MCL_RunApp(&app);
```

or if you want to handle input events (for games or something)

```C++
bool is_running = true;
MCL_Event event;
while(MCL_IsWindowOpen(app.app_window) && is_running)
{
    MCL_PollEvents(&event);
    if (event.type == MCL_KEYBOARDEVENT && event.keycode == MCL_KEY_ESCAPE) 
    {
        is_running = false;
    }
} 
```

7. Deallocate the window and terminate the app
   
```C++
MCL_DestroyWindow(app.app_window);
MCL_TerminateApp(&app);
```