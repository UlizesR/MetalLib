# Mac API

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

1. include <MAC/mac.h> into your main.c file

```C
#include <MAC/mac.h>
```

2. create your main function and initialize MAC

```C
int main() {
    if (MAC_Init(0) != 0) {
        fprintf(stderr, MAC_ERROR_INIZIALIZATION_FAILED);
        return 1;
    }

    // ... rest of code

    return MAC_SUCCESS;
}
```

3. create a window

```C
    MAC_Window* window = createWindow(800, 600, "Test Window");
    if (window == NULL) {
        fprintf(stderr, MAC_ERROR_INIZIALIZATION_FAILED);
        return MAC_ERROR;
    }
```

4. ignore all apps and be the active app (if you are doing input handling)

```C
    ignoreApps();
```

5. create a running loop 

```C
    bool running = true;
    while (running) {
        // GUI code and what not
        // Check if the window is still open
        if (!isWindowOpen(window)) {
            running = false;
        }
    }
```

6. Deallocate any allocated memory 

```C
    destroyWindow(window);
    MAC_Quit();
```