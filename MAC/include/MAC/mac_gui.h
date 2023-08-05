#ifndef MAC_GUI_H_
#define MAC_GUI_H_

#include "mac_view.h"
#include <stdint.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

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


typedef struct Mac_Button {
    int width, height;
    int x, y;
    const char* title;
    uint32_t style;
    uint32_t type;
    Mac_View* parent_view;
} Mac_Button;

void createButton(Mac_Button* button);

// Mac_Button* add_momentary_light_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_push_on_push_off_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_toggle_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_switch_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_radio_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_momentary_change_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_on_off_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_momentary_push_in_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_accelerator_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);
// Mac_Button* add_multi_level_accelerator_button(int width, int height, int x, int y, const char* title, Mac_View* parent_view);

void destroyButton(Mac_Button* button);

#ifdef __cplusplus
}
#endif

#endif // MAC_GUI_H_