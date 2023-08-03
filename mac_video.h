#ifndef MAC_VIDEO_H_
#define MAC_VIDEO_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Video_Display {
    const char *name;
    int width;
    int height;
    double refreshRate;
    // ... add other display information as needed
} Video_Display;

Video_Display* getConnectedDisplays(int* count);
void printDisplayInfo(Video_Display* displays, int count);
void freeDisplays(Video_Display* displays, int count);

#ifdef __cplusplus
}
#endif


#endif  // MAC_VIDEO_H_
