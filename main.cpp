#include <MCL/MCL.h>
#include <stdbool.h>
#include <stdio.h>

#include <iostream>

#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600

int main() {
  if (M_Init(0) != 0) {
    fprintf(stderr, "Error: M_Init() failed\n");
    return 1;
  }

  std::cout << "Hello World!" << std::endl;

  M_Window *window =
      M_CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, true, "MCL Window",
                     M_WINDOW_RESIZABLE | M_WINDOW_MINIMIZED);
  if (window == NULL) {
    fprintf(stderr, "Error: M_CreateWindow() failed\n");
    M_Quit();
    return 1;
  }
  M_AddContentView(window, M_COLOR_BLACK);

  while (M_IsWindowOpen(window)) {
    runDelegate();
  }

  M_DestroyWindow(window);
  M_Quit();

  return 0;
}