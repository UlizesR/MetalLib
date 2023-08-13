# Mac API (MACA)

## About

A C wrapper api that acts something similar to the Window's API (window.h)
It's meant to allow macOS and iOS development using C/C++ instead of just using Objectice-C or Swift.
For those of us who like to use C and C++ that is.

Its style of usage and architecture is very similar to SDL2 as I use the SDL2 source code
as my reference as to how to go about certain things

## Tools and Technologies

#### Languages:

* C
* Objective-C

#### Frameworks

* Cocoa
* Metal

No usage of non in built libraries or frameworks so far
    
## How to Use

You will need to download the library using CMake or Homebrew
(I need to package the libray into a Homebrew Formula)

The style of the code is very similar to SDL2. 
So if you are familiar with SDL2 you will be able to use this library.

#### Code Example

How to make a window

1. include <MACA/maca.h> into your main.c file

```C
#include <MACA/maca.h>
```

2. create your main function and initialize MAC

```C
int main(int argc, const char * argv[]) {
    // Initialize the application
    if(M_Init(0) != 0) {
        fprintf(stderr, "Failed to initialize MACA\n");
        return 1;
    }

    // ... rest of code

    return 0;
}
```

3. create a window and a content view

```C
    M_Window* mainWindow = M_CreateWindow(800, 600, true, "Main Window", 0);
    M_View* contentView = M_AddContentView(mainWindow, M_COLOR_WHITE, M_VIEW_TYPE_NORMAL, NULL);
```

4. create a running loop 

```C
    bool running = true;
    M_Event event;
    while (running) {
        // causes window to remain open
        while (M_PollEvent(&event) != 0) { // Poll for events
            // do event handling
        }
        // Check if the window is still open
        if (!isWindowOpen(mainWindow)) {
            running = false;
        }
    }
```

5. Deallocate any allocated memory 

```C
    M_DestroyView(contentView);
    M_DestroyWindow(mainWindow);
    M_Quit();
```