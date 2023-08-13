#pragma once

#include "mac_defs.h"
#include "mac_gui.h"

#include <stdint.h>
#include <stdbool.h>
#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h> // Include for associated objects

@interface NSMac_Button : NSButton
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
    MAC_BUTTON_STYLE_NONE               = 0,
    MAC_BUTTON_STYLE_ROUNDED            = 1,
    MAC_BUTTON_STYLE_REGULAR_SQUARE     = 2,
    MAC_BUTTON_STYLE_DISCLOSURE         = 5,
    MAC_BUTTON_STYLE_SHADOWLESS_SQUARE  = 6,
    MAC_BUTTON_STYLE_CIRCULAR           = 7,
    MAC_BUTTON_STYLE_TEXTURED_SQUARE    = 8,
    MAC_BUTTON_STYLE_HELP_BUTTON        = 9,
    MAC_BUTTON_STYLE_SMALL_SQUARE       = 10,
    MAC_BUTTON_STYLE_TEXTURED_ROUNDED   = 11,
    MAC_BUTTON_STYLE_ROUND_RECT         = 12,
    MAC_BUTTON_STYLE_RECESSED           = 13,
    MAC_BUTTON_STYLE_ROUNDED_DISCLOSURE = 14,
    MAC_BUTTON_STYLE_INLINE             = 15,
} Mac_Button_Style_Flags;

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
    MAC_BUTTON_TYPE_MOMENTARY_LIGHT            = 0,
    MAC_BUTTON_TYPE_PUSH_ON_PUSH_OFF           = 1,
    MAC_BUTTON_TYPE_TOGGLE                     = 2,
    MAC_BUTTON_TYPE_SWITCH                     = 3,
    MAC_BUTTON_TYPE_RADIO                      = 4,
    MAC_BUTTON_TYPE_MOMENTARY_CHANGE           = 5,
    MAC_BUTTON_TYPE_ON_OFF                     = 6,
    MAC_BUTTON_TYPE_MOMENTARY_PUSH_IN          = 7,
    MAC_BUTTON_TYPE_ACCELERATOR                = 8,
    MAC_BUTTON_TYPE_MULTI_LEVEL_ACCELERATOR    = 9,
} Mac_Button_Type_Flags;

/*
    Function pointer for the button action
    takes a pointer to the button that was clicked

*/
typedef void (*ButtonAction)(Mac_Button*, void* user_data);

/*
    This is the struct that holds all the information for the button
*/
struct Mac_Button {
    MSize size;             // The size of the button
    MPoint position;        // The position of the button
    MTitle title;           // The title of the button
    Mac_View* parent_view;  // The parent view of the button
    ButtonAction action;    // The action of the button
    void* user_data;        // The data that is being targeted by the button
    int tag;                // The tag of the button
    MImage image;           // The image of the button
    void* _this;            // The pointer to this button
};

/*!
    Creates a button with the MAC_BUTTON_STYLE_REGULAR_SQUARE style
    its size are base on the font size and the title length
    @param size The size of the button.
    @param position The position of the button.
    @param title The title of the button.
    @param image The image of the button.
    @param type The type of the button.
    @param font_size The font size of the button's title.
    @param isBordered Whether the button is bordered.
    @param bordered_when_hovered Whether the button is bordered when hovered.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param user_data The data that is being targeted by the button
    @return A pointer to the button.
*/
Mac_Button* MAC_ButtonRS(MSize size, MPoint position, MImage image, MTitle title,  UInt32 type, int font_size, bool isBordered, bool bordered_when_hovered, Mac_View* parent_view, ButtonAction action, void* user_data);

/*!
    Creates a standard push button with a title and image.
    @param size The size of the button.
    @param position The position of the button.
    @param title The title of the button.
    @param image The image of the button.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param user_data The data that is being targeted by the button
    @return A pointer to the button.
*/
Mac_Button* MAC_ButtonSpbTita(MSize size, MPoint position, MTitle title, MImage image, Mac_View* parent_view, ButtonAction action, void* user_data);

/*!
    Creates a standard push button with the provided title.
    @param size The size of the button.
    @param position The position of the button.
    @param title The title of the button.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param user_data The data that is being targeted by the button
    @return A pointer to the button.
*/
Mac_Button* MAC_ButtontSpbTta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action, void* user_data);

/*!
    Creates a standard push button with the provided image.
    @param size The size of the button.
    @param position The position of the button.
    @param image The image of the button.
    @param parent_view The parent view of the button.
    @param action The action of the button.
    @param user_data The data that is being targeted by the button
    @return A pointer to the button.
*/
Mac_Button* MAC_ButtonSpbIta(MSize size, MPoint position, MImage image, Mac_View* parent_view, ButtonAction action, void* user_data);

/*!
    Creates a standard checkbox with the provided title.
    @param size The size of the checkbox.
    @param position The position of the checkbox.
    @param title The localized title string that is displayed alongside the checkbox.
    @param parent_view The parent view of the checkbox.
    @param action The action message sent by the control.
    @return An initialized button object.
 */
Mac_Button* MAC_ButtonScbTta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action, void* user_data);

/*!
    Creates a standard radio with the provided image.
    @param size The size of the radio.
    @param position The position of the radio.
    @param title The localized title string that is displayed alongside the radio.
    @param parent_view The parent view of the radio.
    @param action The action message sent by the control.
    @return An initialized button object.
*/
Mac_Button* MAC_ButtonSrbTta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action, void* user_data);

/*!
    Creates a standard radio with the provided image.
    @param size The size of the radio.
    @param position The position of the radio.
    @param image The image of the radio.
    @param parent_view The parent view of the radio.
    @param action The action message sent by the control.
    @return An initialized button object.
*/
void MAC_HideButton(Mac_Button* button);

/*!
    Shows a button.
    @param button The button to show.
*/
void MAC_ShowButton(Mac_Button* button);

/*!
    Destroys a button.
    @param button The button to destroy.
*/
void MAC_DestroyButton(Mac_Button* button);

#ifdef __cplusplus
}
#endif