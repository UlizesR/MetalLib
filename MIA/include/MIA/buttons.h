#pragma once

#include "defs.h"
#include "internals.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface M_NSButton : NSButton
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif
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
typedef enum 
{
    M_BUTTON_STYLE_NONE               = 0,
    M_BUTTON_STYLE_ROUNDED            = 1,
    M_BUTTON_STYLE_REGULAR_SQUARE     = 2,
    M_BUTTON_STYLE_DISCLOSURE         = 5,
    M_BUTTON_STYLE_SHADOWLESS_SQUARE  = 6,
    M_BUTTON_STYLE_CIRCULAR           = 7,
    M_BUTTON_STYLE_TEXTURED_SQUARE    = 8,
    M_BUTTON_STYLE_HELP_BUTTON        = 9,
    M_BUTTON_STYLE_SMALL_SQUARE       = 10,
    M_BUTTON_STYLE_TEXTURED_ROUNDED   = 11,
    M_BUTTON_STYLE_ROUND_RECT         = 12,
    M_BUTTON_STYLE_RECESSED           = 13,
    M_BUTTON_STYLE_ROUNDED_DISCLOSURE = 14,
    M_BUTTON_STYLE_INLINE             = 15,
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
typedef enum 
{
    M_BUTTON_TYPE_MOMENTARY_LIGHT            = 0,
    M_BUTTON_TYPE_PUSH_ON_PUSH_OFF           = 1,
    M_BUTTON_TYPE_TOGGLE                     = 2,
    M_BUTTON_TYPE_SWITCH                     = 3,
    M_BUTTON_TYPE_RADIO                      = 4,
    M_BUTTON_TYPE_MOMENTARY_CHANGE           = 5,
    M_BUTTON_TYPE_ON_OFF                     = 6,
    M_BUTTON_TYPE_MOMENTARY_PUSH_IN          = 7,
    M_BUTTON_TYPE_ACCELERATOR                = 8,
    M_BUTTON_TYPE_MULTI_LEVEL_ACCELERATOR    = 9,
} M_Button_Type_Flags;

/*
    This is the struct that holds all the information for the button
*/
typedef struct M_Button {
    MSize size;             // The size of the button
    MPoint position;        // The position of the button
    MTitle title;           // The title of the button
    M_View* parent_view;    // The parent view of the button
    Action action;          // The action of the button
    MImage image;           // The image of the button
    void* data;             // The data that is being targeted by the button
    int tag;                // The tag of the button
    void* _this;            // The pointer to this button
} M_Button;

/*!
    Creates a standard push button with a title and image.
    @param size The size of the button.
    @param position The position of the button.
    @param title The title of the button.
    @param image The image of the button.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param data The data that is being targeted by the button
    @return A pointer to the button.
*/
M_Button* M_ButtonSpb1(MSize size, MPoint position, MTitle title, MImage image, M_View* parent_view, Action action, void* data);

/*!
    Creates a standard push button with the provided title.
    @param size The size of the button.
    @param position The position of the button.
    @param title The title of the button.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param data The data that is being targeted by the button
    @return A pointer to the button.
*/
M_Button* M_ButtontSpb2(MSize size, MPoint position, MTitle title, M_View* parent_view, Action action, void* data);

/*!
    Creates a standard push button with the provided image.
    @param size The size of the button.
    @param position The position of the button.
    @param image The image of the button.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param data The data that is being targeted by the button
    @return A pointer to the button.
*/
M_Button* M_ButtonSpb3(MSize size, MPoint position, MImage image, M_View* parent_view, Action action, void* data);

/*!
    Creates a standard checkbox with the provided title.
    @param size The size of the checkbox.
    @param position The position of the checkbox.
    @param title The localized title string that is displayed alongside the checkbox.
    @param parent_view The parent view of the checkbox.
    @param action The action message sent by the control.
    @param data The data that is being targeted by the button
    @return An initialized button object.
 */
M_Button* M_ButtonScb(MSize size, MPoint position, MTitle title, M_View* parent_view, Action action, void* data);

/*!
    Creates a standard radio with the provided image.
    @param size The size of the radio.
    @param position The position of the radio.
    @param title The localized title string that is displayed alongside the radio.
    @param parent_view The parent view of the radio.
    @param action The action message sent by the control.
    @param data The data that is being targeted by the button
    @return An initialized button object.
*/
M_Button* M_ButtonSrb(MSize size, MPoint position, MTitle title, M_View* parent_view, Action action, void* data);

/*!
    Creates a standard radio with the provided image.
    @param size The size of the radio.
    @param position The position of the radio.
    @param image The image of the radio.
    @param parent_view The parent view of the radio.
    @param action The action message sent by the control.
    @param data The data that is being targeted by the button
    @return An initialized button object.
*/
void M_HideButton(M_Button* button);

/*!
    Shows a button.
    @param button The button to show.
*/
void M_ShowButton(M_Button* button);

/*!
    Destroys a button.
    @param button The button to destroy.
*/
void M_DestroyButton(M_Button* button);

#ifdef __cplusplus
}
#endif