#ifndef _M_VIEW_H_
#define _M_VIEW_H_

#include "MColor.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif 

#include "MError.h"
#include "MDefs.h"

struct MView 
{
    int width, height;
    float x, y;
    float cornerRadius;
    MColor backgroundColor;
    MBool isContentView;
    MBool resizable;
    MWindow *window;
#ifdef __OBJC__
    NSView *_view;
#endif // __OBJC__
};

/*!
    * @brief Creates the content view of the window.
    * @param window The window.
    * @param backgroundColor The background color of the content view.
*/
MAPI void MCreateContentView(MWindow *window, MColor backgroundColor);

/*!
    * @brief Creates a sub view.
    * @param parent The parent view.
    * @param x The x position of the view.
    * @param y The y position of the view.
    * @param width The width of the view.
    * @param height The height of the view.
    * @param backgroundColor The background color of the view.
    * @param resizable Whether the view is resizable.
    * @param cornerRadius The corner radius of the view.
    * @return MView* 
*/
MAPI MView  *MCreateSubView(MView *parent, int x, int y, int width, int height, MColor backgroundColor, MBool resizable, float cornerRadius);

/*!
    * @brief Hides the view.
    * @param View The view.
*/
MAPI void MHideView(MView *View);

/*!
    * @brief Shows the view.
    * @param View The view.
*/
MAPI void MShowView(MView *View);

/*!
    * @brief Deallocates the view from memory. Doesnt need to be called for content views. The window destroys them automatically when it is destroyed.
    * @param View The view.
*/
MAPI void MDestroyView(MView *View);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _M_VIEW_H_