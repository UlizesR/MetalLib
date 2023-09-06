#ifndef _mcl_labels_h_
#define _mcl_labels_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_Label {
    const char *text;       // The text of the label
    const char *font;       // The font of the label
    int x, y;               // The x and y coordinates of the label
    int font_size;          // The font size of the label
    MCL_Color color;        // The color of the label
} MCL_Label;    

/*!
    @brief Creates a label and adds it to the frame.
    @param frame The frame to add the label to.
    @param label The label to add to the frame.
*/
void MCL_AddLabel(MCL_Frame *frame, MCL_Label label);

/*!
    @brief Removes a label from the frame.
    @param frame The frame to remove the label from.
    @param label The label to remove from the frame.
*/
void MCL_RemoveLabel(MCL_Frame *frame, MCL_Label label);

/*!
    @brief Gets the available fonts on the system.
*/
void MCL_GetAvailableFonts();

#ifdef __cplusplus
}
#endif

#endif // _mcl_labels_h_