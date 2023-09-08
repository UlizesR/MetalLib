#ifndef _mcl_labels_h_
#define _mcl_labels_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_Text_S
{
    int w, h;
} MCL_Text_S;

typedef struct MCL_Text
{
    MCL_Text_S size;
    const char *text;
    const char *font;
    int font_size;
    MCL_Color color;
    void *_this;
} MCL_Text;

/*!
    @brief Adds text to the frame.
    @param sText The text that needs to be modified.
    @param frame The frame to add the text to.
    @param x The x coordinate of the text.
    @param y The y coordinate of the text.
    @param text The text to add to the frame.
    @param font The font of the text.
    @param font_size The font size of the text.
    @param color The color of the text.
*/
void MCL_AddText(MCL_Frame *frame, MCL_Text *sText, int x, int y, const char *text, const char *font, int font_size, MCL_Color color);

/*!
    @brief Gets the size of the text.
    @param text The text to get the size of.
    @param font The font of the text.
    @param font_size The font size of the text.
    @return The size of the text.
*/
MCL_Text_S MCL_GetTextSize(const char *text, const char *font, int font_size);

/*!
    @brief Removes text from the frame.
    @param frame The frame to remove the text from.
    @param sText The text to remove from the frame.
*/
void MCL_RemoveText(MCL_Frame *frame, MCL_Text *sText);

/*!
    @brief Gets the available fonts on the system.
*/
void MCL_GetAvailableFonts();

#ifdef __cplusplus
}
#endif

#endif // _mcl_labels_h_