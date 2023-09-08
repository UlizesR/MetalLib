#ifndef _mcl_labels_h_
#define _mcl_labels_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MText_s
{
    int w, h;
} MText_s;

/*!
    @brief Adds text to the frame.
    @param frame The frame to add the text to.
    @param x The x coordinate of the text.
    @param y The y coordinate of the text.
    @param text The text to add to the frame.
    @param font The font of the text.
    @param font_size The font size of the text.
    @param color The color of the text.
*/
void MCL_AddText(MCL_Frame *frame,int x, int y, const char *text, const char *font, int font_size, MCL_Color color);

/*!
    @brief Gets the size of the text.
    @param text The text to get the size of.
    @param font The font of the text.
    @param font_size The font size of the text.
    @return The size of the text.
*/
MText_s MCL_GetTextSize(const char *text, const char *font, int font_size);

/*!
    @brief Gets the available fonts on the system.
*/
void MCL_GetAvailableFonts();

#ifdef __cplusplus
}
#endif

#endif // _mcl_labels_h_