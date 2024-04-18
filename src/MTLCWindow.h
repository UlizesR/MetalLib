#ifndef _MTLC_WINDOW_H_
#define _MTLC_WINDOW_H_

#include "MTLCDefs.h"
#include "MTLCError.h"
#include <stdint.h>

#ifdef __OBJC2__
#import <Cocoa/Cocoa.h>

@interface MTLCDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (nonatomic, strong, nonnull) NSWindow *window;

- (instancetype)initWithWindowWithErr:(MTLCError *)error;

@end
#else
typedef void* id;
#endif

struct MTLCWindow {
    const char* title;
    const char* icon;
    int width, height;
    uint32_t flags;
    char w_id;          // Window ID, only 1 byte long
    struct {
        id object;
        id contentView;
    } ns;
};

MTLCWindow* MTLCCreateWindow(const char* title, int width, int height, MTLCError* error);

bool MTLCIsWindowOpen(MTLCWindow* window);

void MTLCCloseWindow(MTLCWindow* window);

void MTLCDestroyWindow(MTLCWindow* window);

#endif // _MTLC_WINDOW_H_