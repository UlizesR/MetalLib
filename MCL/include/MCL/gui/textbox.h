#ifndef _mcl_textbox_h_
#define _mcl_textbox_h_

#include "../../MCL/colors.h"
#include "../../MCL/defs.h"
#include <objc/objc.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface tbdelegate : NSObject <NSTextFieldDelegate, NSTextViewDelegate>

@property(nonatomic, strong) NSMutableString *text;
@property(nonatomic, strong) NSTextView *textField;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

/*!
    @brief Creates a textbox and adds it to the frame.
    @param frame The frame to add the textbox to.
*/
void MCL_AddTextBox(MCL_Frame *frame, int x, int y, int width, int height, const char* text, const char* font, int font_size, MCL_Color bg_color, MCL_Color text_color);

/*!
    @brief Clears the textbox.
    @param textbox The textbox to clear.
*/
// void MCL_ClearTextBox(MCL_TextBox *textbox);

#ifdef __cplusplus
}
#endif

#endif // _mcl_textbox_h_