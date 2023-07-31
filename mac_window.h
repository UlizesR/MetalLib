#ifndef MAC_WINDOW_H_
#define MAC_WINDOW_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __OBJC__
#endif

typedef void* Window;



Window createWindow(int width, int height, const char* title);
void runWindow();

#ifdef __cplusplus
}
#endif

#endif // MAC_WINDOW_H_