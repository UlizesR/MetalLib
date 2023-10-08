/*
    File:   MCLLabel.h
    About:
        The header file for the MCLLabel class.
        This class is used for creating GUIs.
*/

#ifndef _mcl_label_h_
#define _mcl_label_h_

#include "MCL2/MCLCore/MCLCore.h" 
#include "MCL2/MCLCore/MCLColors.h"

typedef struct MCL_Label_S {
  int w, h;
} MCL_Label_S;

typedef struct MCL_Label {
  MCL_Label_S size;
  const char *Label;
  const char *font;
  int font_size;
  MCL_Color color;
  void *_this;
} MCL_Label;

/*!
    @brief Adds Label to the View.
    @param sLabel The Label that needs to be modified.
    @param View The View to add the Label to.
    @param x The x coordinate of the Label.
    @param y The y coordinate of the Label.
    @param Label The Label to add to the View.
    @param font The font of the Label.
    @param font_size The font size of the Label.
    @param color The color of the Label.
*/
void MCL_AddLabel(MCL_View *View, MCL_Label *sLabel, int x, int y, const char *Label, const char *font, int font_size, MCL_Color color);

/*!
    @brief Gets the size of the Label.
    @param Label The Label to get the size of.
    @param font The font of the Label.
    @param font_size The font size of the Label.
    @return The size of the Label.
*/
MCL_Label_S MCL_GetLabelSize(const char *Label, const char *font, int font_size);

/*!
    @brief Removes Label from the View.
    @param View The View to remove the Label from.
    @param sLabel The Label to remove from the View.
*/
void MCL_RemoveLabel(MCL_View *View, MCL_Label *sLabel);

/*!
    @brief Gets the available fonts on the system.
*/
void MCL_GetAvailableFonts();

#endif  /* _mcl_label_h_ */