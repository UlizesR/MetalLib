#include <MCL/MCL.h>
#include <stdbool.h>
#include <stdio.h>


int main() {
  if (M_Init(0) != 0) {
    fprintf(stderr, "Error: M_Init() failed\n");
    return 1;
  }

  M_Window *window = M_CreateWindow(800, 600, true, "MCL Window",
                                    M_WINDOW_RESIZABLE | M_WINDOW_MINIMIZED);
  if (window == NULL) {
    fprintf(stderr, "Error: M_CreateWindow() failed\n");
    M_Quit();
    return 1;
  }
  M_AddContentView(window, M_COLOR_CYAN_8);

  M_Point *point = M_CreatePoint(100, 600, M_COLOR_BLACK);
  M_DrawPoint(window->content_view, point);

  M_Line *line = M_CreateLine((MFPoint){100, 100}, (MFPoint){200, 100},  1, M_COLOR_BLACK);
  M_DrawLine(window->content_view, line);

  while (M_IsWindowOpen(window)) {
    runDelegate();
  }

  M_DestroyShape((M_Shape*)point);
  M_DestroyWindow(window);
  M_Quit();

  return 0;
}