#ifndef _M_VIEW_H_
#define _M_VIEW_H_

#include "MColor.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "MDefs.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif 

struct MView 
{
    int width, height;
    float x, y;
    float cornerRadius;
    MColor backgroundColor;
    MBool resizable;
    MWindow *window;
    void *_this;
};

void MCreateContentView(MWindow *window, MColor backgroundColor);

MView  *MCreateSubView(MView *parent, int x, int y, int width, int height, MColor backgroundColor, MBool resizable, float cornerRadius);

void MHideView(MView *View);

void MShowView(MView *View);

void MDestroyView(MView *View);

#ifdef __cplusplus
}
#endif

#endif // _M_VIEW_H_