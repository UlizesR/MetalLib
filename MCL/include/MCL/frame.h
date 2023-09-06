#ifndef _mcl_frame_h_
#define _mcl_frame_h_

#include "defs.h"
#include "colors.h"

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
    Struct for the frame of a view
    in macOS, this is the NSView and in iOS, this is the UIView
    a view is the same as a frame in macOS and iOS
*/
struct MCL_Frame {
    int width, height;              // The size of the view
    int x, y;                       // The position of the view
    MCL_Color bg_color;     // The background color of the view
    float corner_radius;            // The corner radius of the view
    void *_this;                    // The view itself
};

/*!
    @brief Creates the Window's main frame (the content view)
    The frame will be deallocated when the window is destroyed
    @param window: the window to create the frame for
    @param color: the color of the frame
*/
void MCL_SetWindowFrame(MCL_Window *window, MCL_Color color);

/*!
    @brief Creates a frame that is a subview of another frame
    @param pframe: the frame to create the subview for
    @param cframe: the frame to create the subview from
*/
void MCL_AddFrame(MCL_Frame *pframe, MCL_Frame *cframe, bool resizable);

/*!
    @brief Changes the background color of the frame
    @param frame: the frame to change the background color of
    @param color: the new background color of the frame
*/
void MCL_ChangeFrameColor(MCL_Frame *frame, MCL_Color color);

/*!
    @brief Hides the frame
    @param frame: the frame to hide
*/
void MCL_HideFrame(MCL_Frame *frame);

/*!
    @brief Shows the frame
    @param frame: the frame to show
*/
void MCL_ShowFrame(MCL_Frame *frame);

#ifdef __cplusplus
}
#endif

#endif // _mcl_frame_h_