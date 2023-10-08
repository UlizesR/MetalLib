# MCL API (macOS applications)

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

## How to install

Install using cmake after clonning the repo.

```cmake
mkdir build
cd build
cmake ..

sudo make and make install
```

For now it uses cmake to install locally to the machine but I am planning on using Homebrew in the future.

## How to use the MCL Library


Getting an app window going

1. Include the MCL2 Core library 
```C++
#include <MCL2/MCLCore/MCLApplication.h>
```

1. Initilized the app state
   
```C++
MCL_App app = {
    .app_info = {
        .name = "Example App",
        .version = MCL_APP_VERSION(1, 0, 0),
        .author = "me",
        .description = "An example app",
    },
    .app_window = NULL,
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

5. Create the app's main window, set the window's hint and it content view (The main frame)
   
```C++
MCL_AppWindow(&app, 800, 600, "Example Window");
MCL_WindowHints(app.app_window, MCL_WINDOW_RESIZABLE | MCL_WINDOW_MINIMIZED);
MCL_SetWindowView(app.app_window, MCL_COLOR_BLACK);
```

6. Add the run loop for the app

```C++
MCL_Event event;
while(MCL_IsWindowOpen(app.app_window))
{
    MCL_PollEvents(&event);
} 
```

7. Deallocate the window and terminate the app
   
```C++
MCL_DestroyWindow(app.app_window);
MCL_TerminateApp(&app);
```