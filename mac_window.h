#ifndef MAC_WINDOW_H_
#define MAC_WINDOW_H_

typedef void* Window;

#ifdef __cplusplus
extern "C" {
#endif

Window createWindow(int width, int height, const char* title);
void runWindow();

#ifdef __cplusplus
}
#endif

#endif // MAC_WINDOW_H_