#pragma once

#include "defs.h"
#include "colors.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface NSM_Text : NSTextField
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct M_Text {
    MPoint pos;              // Position of the text
    MSize size;              // Size of the text
    M_Color color;         // Color of the text
    M_View* parent_view;   // Parent view
    int id;                  // ID of the text
    MText text;              // Text to display
    int font;                // Font to use
    int text_length;         // Length of the text
    void* _this;             // Pointer to the text object
} M_Text;

/*!
    Creates a new text object and adds it to the view.
    @param parent_view The view to add the text to.
    @param pos The position of the text.
    @param size The size of the text.
    @param color The color of the text.
    @param text The text to display.
    @param font The font to use.
    @return The created text object.
*/
M_Text* M_AddText(M_View* parent_view, MPoint pos, MSize size, M_Color color, MText text, int font);

/*!
    Updates the text of a text object.
    @param text The text object to update.
    @param newText The new text to display.
*/
void M_UpdateText(M_Text* text, MText newText);

/*!
    MText is of typedef const char*
    Gets the pixel size (width, height) of a text object.
    @param text the text string to get the size of.
    @param font The font size.
    @return The size of the text object.
*/
MSize M_GetTextSize(MText text, int font);

/*!
    Removes a text object from the view.
    @param text The text object to remove.
*/
void M_RemoveText(M_Text* text);

/*!
    Destroys a text object.
    @param text The text object to destroy.
*/
void M_DestroyText(M_Text* text);

#ifdef __cplusplus
}
#endif