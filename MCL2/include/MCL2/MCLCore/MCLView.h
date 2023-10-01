/*
    File: MCLView.h
    About:
        The View header file for MCL.
        Contains the View for MCL.
*/

#ifndef _mcl_View_h_
#define _mcl_View_h_

#include "MCLColors.h"
#include "MCLWindow.h"

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

struct MCL_View {
  int width, height;   // The size of the view
  int x, y;            // The position of the view
  MCL_Color bg_color;  // The background color of the view
  float corner_radius; // The corner radius of the view
  void *_this;         // The view itself
};

/*!
    @brief Creates the Window's main View (the content view)
    The View will be deallocated when the window is destroyed
    @param window: the window to create the View for
    @param color: the color of the View
*/
void MCL_SetWindowView(MCL_Window *window, MCL_Color color);

/*!
    @brief Creates a View that is a subview of another View
    @param pView: the View to create the subview for
    @param cView: the View to create the subview from
*/
void MCL_AddView(MCL_View *pView, MCL_View *cView, bool resizable);

/*!
    @brief Changes the background color of the View
    @param View: the View to change the background color of
    @param color: the new background color of the View
*/
void MCL_ChangeViewColor(MCL_View *View, MCL_Color color);

/*!
    @brief Hides the View
    @param View: the View to hide
*/
void MCL_HideView(MCL_View *View);

/*!
    @brief Shows the View
    @param View: the View to show
*/
void MCL_ShowView(MCL_View *View);

#ifdef __cplusplus
}
#endif

#endif // _mcl_View_h_