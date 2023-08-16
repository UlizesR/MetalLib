#pragma once

#include "defs.h"
#include "colors.h"

#include <MacTypes.h>
#include <stdbool.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface M_NSView: NSView;
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

struct M_View
{
    int id;                         // The id of the view
    MSize size;                     // The size of the view
    MPoint position;                // The position of the view
    M_Color background_color;       // The background color of the view
    M_View *parent;                 // The parent view of the view
    float corner_radius;            // The corner radius of the view
    void *_this;                    // The view itself
}; // The view

/*!
    Creates a sub view with the given parameters.
    @param parent: the parent view of the view
    @param width: the width of the view
    @param height: the height of the view
    @param x: the x position of the view
    @param y: the y position of the view
    @param corner_radius: the corner radius of the view
    @param background_color: the background color of the view
    @return: the created sub view
*/
M_View* M_AddSubView(M_View* parent, int width, int height, int x, int y, float corner_radius, bool resizable, M_Color background_color);

/*!
    Creates a given window's content view with the given parameters.
    @param parent: the parent window of the view
    @param background_color: the background color of the view
    @return: the created content view
*/
void M_AddContentView(M_Window* parent, M_Color background_color);

/*!
    Changes the Color of the given view.
    @param view: the view to be changed
    @param color: the new color of the view
*/
void M_ChangeViewBGColor(M_View* view, M_Color color);

/*!
    Hides the given view.
    @param view: the view to be hidden
*/
void M_HideView(M_View* view);

/*!
    Shows the given view.
    @param view: the view to be shown
*/
void M_ShowView(M_View* view);

/*!
    Destroys the given view.
    @param view: the view to be destroyed
*/
void M_DestroyView(M_View* view);

#ifdef __cplusplus
}
#endif
