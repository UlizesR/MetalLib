#ifndef _mcl_buttons_h_
#define _mcl_buttons_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

/*
    This is base of the current NSButtonCell.h button styles
    NSBezelStyleRounded           = 1,
    NSBezelStyleRegularSquare     = 2,
    NSBezelStyleDisclosure        = 5,
    NSBezelStyleShadowlessSquare  = 6,
    NSBezelStyleCircular          = 7,
    NSBezelStyleTexturedSquare    = 8,
    NSBezelStyleHelpButton        = 9,
    NSBezelStyleSmallSquare       = 10,
    NSBezelStyleTexturedRounded   = 11,
    NSBezelStyleRoundRect         = 12,
    NSBezelStyleRecessed          = 13,
    NSBezelStyleRoundedDisclosure = 14,
    NSBezelStyleInline API_AVAILABLE(macos(10.7)) = 15,
*/
typedef enum {
  M_BUTTON_STYLE_NONE = 0,
  M_BUTTON_STYLE_ROUNDED = 1,
  M_BUTTON_STYLE_REGULAR_SQUARE = 2,
  M_BUTTON_STYLE_DISCLOSURE = 5,
  M_BUTTON_STYLE_SHADOWLESS_SQUARE = 6,
  M_BUTTON_STYLE_CIRCULAR = 7,
  M_BUTTON_STYLE_TEXTURED_SQUARE = 8,
  M_BUTTON_STYLE_HELP_BUTTON = 9,
  M_BUTTON_STYLE_SMALL_SQUARE = 10,
  M_BUTTON_STYLE_TEXTURED_ROUNDED = 11,
  M_BUTTON_STYLE_ROUND_RECT = 12,
  M_BUTTON_STYLE_RECESSED = 13,
  M_BUTTON_STYLE_ROUNDED_DISCLOSURE = 14,
  M_BUTTON_STYLE_INLINE = 15,
} M_Button_Style_Flags;

/*
    This is base of the current NSButtonCell.h button types
    NSButtonTypeMomentaryLight    = 0,
    NSButtonTypePushOnPushOff     = 1,
    NSButtonTypeToggle            = 2,
    NSButtonTypeSwitch            = 3,
    NSButtonTypeRadio             = 4,
    NSButtonTypeMomentaryChange   = 5,
    NSButtonTypeOnOff             = 6,
    NSButtonTypeMomentaryPushIn   = 7,
    NSButtonTypeAccelerator API_AVAILABLE(macos(10.10.3)) = 8,
    NSButtonTypeMultiLevelAccelerator API_AVAILABLE(macos(10.10.3)) = 9,
*/
typedef enum {
  M_BUTTON_TYPE_MOMENTARY_LIGHT = 0,
  M_BUTTON_TYPE_PUSH_ON_PUSH_OFF = 1,
  M_BUTTON_TYPE_TOGGLE = 2,
  M_BUTTON_TYPE_SWITCH = 3,
  M_BUTTON_TYPE_RADIO = 4,
  M_BUTTON_TYPE_MOMENTARY_CHANGE = 5,
  M_BUTTON_TYPE_ON_OFF = 6,
  M_BUTTON_TYPE_MOMENTARY_PUSH_IN = 7,
  M_BUTTON_TYPE_ACCELERATOR = 8,
  M_BUTTON_TYPE_MULTI_LEVEL_ACCELERATOR = 9,
} M_Button_Type_Flags;

typedef struct MCL_Button
{
    int x, y, w, h;             // position and size
    const char *title;          // title
    const char *icon;           // icon/image

    MCL_ActionCallback action;  // action callback
    M_Button_Style_Flags style; // button style
    M_Button_Type_Flags type; // button type
    
    void *data;                 // data to pass to action callback
    void *_this;                // internal use only
} MCL_Button;

void MCL_AddButtonNF(MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data);

/*!
    * @brief Create a new button
    * @param frame The frame to add the button to
    * @param button The button to create
    * @param x The x position of the button
    * @param y The y position of the button
    * @param w The width of the button
    * @param h The height of the button
    * @param title The title of the button
    * @param action The action callback of the button
    * @param data The data to pass to the action callback
    * @return A new button
*/
void MCL_AddButton(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data);

/*!
    * @brief Set the target and data of a button.
    * @param button The button to set the target and data of.
    * @param target The target of the button.
*/
void MCL_SetButtonTarget(MCL_Button *button, void *target);

/*!
    * @brief Set the Style and Type of a button.
    * @param button The button to set the style and type of.    
    * @param style The style of the button.
    * @param type The type of the button.
*/
void MCL_SetButtonHints(MCL_Button *button, M_Button_Style_Flags style, M_Button_Type_Flags type);

/*!
    * @brief Create a new checkbox
    * @param frame The frame to add the checkbox to
    * @param button The checkbox to create
    * @param x The x position of the checkbox
    * @param y The y position of the checkbox
    * @param w The width of the checkbox
    * @param h The height of the checkbox
    * @param title The title of the checkbox
    * @param action The action callback of the checkbox
    * @param data The data to pass to the action callback
*/
void MCL_AddCheckBox(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data);

/*!
    * @brief Create a new radio button
    * @param frame The frame to add the radio button to
    * @param button The radio button to create
    * @param x The x position of the radio button
    * @param y The y position of the radio button
    * @param w The width of the radio button
    * @param h The height of the radio button
    * @param title The title of the radio button
    * @param action The action callback of the radio button
    * @param data The data to pass to the action callback 
*/
void MCL_AddRadioButton(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data);

/*!
    * @brief Hide a button.
    * @param button The button to hide.
*/
void M_HideButton(MCL_Button *button);

/*!
    * @brief Shows a button.
    * @param button The button to show.
*/
void M_ShowButton(MCL_Button *button);

/*!
    * @brief Removes a button from the frame.
    * @param button The button to remove.
*/
void MCL_RemoveButton(MCL_Button *button);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _mcl_buttons_h_