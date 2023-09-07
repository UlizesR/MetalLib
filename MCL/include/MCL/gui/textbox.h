#ifndef _mcl_textbox_h_
#define _mcl_textbox_h_

#include "../../MCL/colors.h"
#include "../../MCL/defs.h"
#include <objc/objc.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface tbdelegate : NSObject <NSTextFieldDelegate, NSTextViewDelegate>

@property(nonatomic, strong) NSMutableString *text;
@property(nonatomic, strong) NSTextField *textField;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_TextBox 
{
    int x, y;               // The x and y coordinates of the textbox
    int width, height;      // The width and height of the textbox
    MCL_Color bg_color;     // The background color of the textbox
    MCL_Color text_color;   // The text color of the textbox
    const char* text;       // The text of the textbox
    void *_this;            // The textbox itself
} MCL_TextBox;

/*!
    @brief Creates a textbox and adds it to the frame.
    @param frame The frame to add the textbox to.
*/
void MCL_AddTextBox(MCL_Frame *frame, MCL_TextBox *textbox);

/*!
    @brief Clears the textbox.
    @param textbox The textbox to clear.
*/
void MCL_ClearTextBox(MCL_TextBox *textbox);

#ifdef __cplusplus
}
#endif

#endif // _mcl_textbox_h_