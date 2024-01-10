#ifndef _MKL_WINDOW_H_
#define _MKL_WINDOW_H_

// #ifdef __cplusplus
// extern "C" {
// #endif

#ifdef __OBJC__

#import <Cocoa/Cocoa.h>

@interface MklDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (nonatomic, strong, nonnull) NSWindow *window;

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title width:(int)width height:(int)height;
@end

#endif // __OBJC__

#include <stdint.h>

#include "Core/MKLCore.h"

typedef struct MKLWindow
{
    int width, height;      // Window size
    const char *title;      // Window title
    uint32_t flags;         // Window flags
#ifdef __OBJC__
    NSWindow *_nswindow;    // NSWindow
#endif 
} MKLWindow;

MKLAPI MKLWindow *MKLCreateWindow(int width, int height, const char *title);

MKLAPI void MKLCloseWindow(MKLWindow *window);

MKLAPI int MKLWindowShouldClose(MKLWindow *window);

MKLAPI void MKLDestroyWindow(MKLWindow *window);

// #ifdef __cplusplus
// }
// #endif

#endif // _MKL_WINDOW_H_