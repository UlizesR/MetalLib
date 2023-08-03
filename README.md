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

No usage of non in built libraries or frameworks so far
    
## How to Use

I have set up a library that can be downloaded yet. I will fix this.

#### ONCE ITS A LIBRARY

The same way you would go about using SDL2

1. include <MAC/mac.h> into your main.c file

```C
#include <MAC/mac.h>
```

2. create your main function and initialize MAC

```C
int main() {
    if (MAC_Init(0) != 0) {
        printf("Failed to initialize\n");
        return 1;
    }

    // ... rest of code
    return 0;
}
```