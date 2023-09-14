#ifndef _mcl_textbox_h_
#define _mcl_textbox_h_

#include "../../MCL/colors.h"
#include "../../MCL/defs.h"
#include <objc/objc.h>

typedef struct MCL_TextBox MCL_TextBox;

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

struct MCL_TextBox
{
    int x, y, width, height;
    const char *text;
    const char *font;
    int font_size;
    MCL_Color bg_color;
    MCL_Color text_color;
    void *_this;
};

/*!
    @brief Creates a textbox and adds it to the frame.
    @param frame The frame to add the textbox to.
*/
void MCL_AddTextBox(MCL_Frame *frame, MCL_TextBox *textbox, int x, int y, int width, int height, const char* text, const char* font, int font_size, MCL_Color bg_color, MCL_Color text_color);

/*!
    @brief Clears the textbox.
    @param textbox The textbox to clear.
*/
void MCL_ClearTextBox(MCL_TextBox *textbox);

/*!
    @brief Gets the current text from the textbox.
    @param textbox The textbox to get the text from.
*/
void MCL_GetCurrentText(MCL_TextBox *textbox);

/*!
    @brief Changes the font of the textbox.
    @param textbox The textbox to change the font of.
    @param font The font to change to.
*/
void MCL_TBChangeFontSize(MCL_TextBox *textbox, int font_size);

/*!
    @brief Changes the font of the textbox.
    @param textbox The textbox to change the font of.
    @param font The font to change to.
*/
void MCL_TBChangeFont(MCL_TextBox *textbox, const char* font);

#ifdef __cplusplus
}
#endif

#endif // _mcl_textbox_h_