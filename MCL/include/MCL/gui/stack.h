#ifndef _mcl_stack_h_
#define _mcl_stack_h_

#include "../../MCL/colors.h"
#include "../../MCL/defs.h"
#include "./sliders.h"
#include "./buttons.h"
#include "./text.h"
#include "./textbox.h"
#include <_types/_uint32_t.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    MCL_StackDistribution_GravityAreas = 0,
    MCL_StackDistribution_Fill = 0x00000001,
    MCL_StackDistribution_FillEqually = 0x00000002,
    MCL_StackDistribution_FillProportionally = 0x00000004,
    MCL_StackDistribution_EqualSpacing = 0x00000008,
    MCL_StackDistribution_EqualCentering = 0x00000010,
} MCL_StackDistribution;

typedef enum {
    MCL_StackGravity_Leading = 0x00000001,
    MCL_StackGravity_Trailing = 0x00000002,
    MCL_StackGravity_Center = 0x00000004,
    MCL_StackGravity_Top = 0x00000008,
    MCL_StackGravity_Bottom = 0x00000010,
} MCL_StackGravity;

typedef enum {
    MCL_StackAlignment_None = 0,
    MCL_StackAlignment_FirstBaseline = 0x00000001,
    MCL_StackAlignment_LastBaseline = 0x00000002,
    MCL_StackAlignment_CenterX = 0x00000004,
    MCL_StackAlignment_CenterY = 0x00000008,
    MCL_StackAlignment_Top = 0x00000010,
    MCL_StackAlignment_Bottom = 0x00000020,
    MCL_StackAlignment_Left = 0x00000040,
    MCL_StackAlignment_Right = 0x00000080,
    MCL_StackAlignment_Leading = 0x00000100,
    MCL_StackAlignment_Trailing = 0x00000200,
    MCL_StackAlignment_Width = 0x00000400,
    MCL_StackAlignment_Height = 0x00000800,
} MCL_StackAlignment;

typedef struct MCL_Stack 
{
    int spacing;
    int x, y, width, height;
    int count;
    void *_this;
} MCL_Stack;

/*!
    * @brief Creates a new vertical stack.
    * @param frame The frame to add the stack to.
    * @param x The x position of the stack.
    * @param y The y position of the stack.
    * @param width The width of the stack.
    * @param height The height of the stack.
    * @param spacing The spacing between each element in the stack.
*/
void MCL_VStack(MCL_Frame *frame, MCL_Stack *stack, int x, int y, int width, int height, int spacing);

/*!
    * @brief Creates a new horizontal stack.
    * @param frame The frame to add the stack to.
    * @param x The x position of the stack.
    * @param y The y position of the stack.
    * @param width The width of the stack.
    * @param height The height of the stack.
    * @param spacing The spacing between each element in the stack.
*/
void MCL_HStack(MCL_Frame *frame, MCL_Stack *stack, int x, int y, int width, int height, int spacing);

/*!
    * @brief Sets the insets of the stack.
    * @param stack The stack to set the insets for.
    * @param top The top inset.
    * @param left The left inset.
    * @param bottom The bottom inset.
    * @param right The right inset.
*/
void MCL_StackSetInsets(MCL_Stack *stack, int top, int left, int bottom, int right);

/*!
    * @brief Sets stack hints for distribution and alignment.
    * @param stack The stack to set the hints for.
    * @param distribution The distribution of the stack.
    * @param alignment The alignment of the stack.
*/
void MCL_StackHints(MCL_Stack *stack, uint32_t distribution, uint32_t alignment);

/*!
    * @brief adds a button to the stack.
    * @param stack The stack to add the button to.
    * @param button The button to add to the stack.
*/
void MCL_Stack_Add_Button(MCL_Stack *stack, MCL_Button *button, uint32_t gravity);

/*!
    * @brief adds a slider to the stack.
    * @param stack The stack to add the slider to.
    * @param slider The slider to add to the stack.
*/
void MCL_Stack_Add_Slider(MCL_Stack *stack, MCL_Slider *slider, uint32_t gravity);

/*!
    * @brief adds a text to the stack.
    * @param stack The stack to add the text to.
    * @param text The text to add to the stack.
*/
void MCL_Stack_Add_Text(MCL_Stack *stack, MCL_Text *text, uint32_t gravity);

/*!
    * @brief adds a frame to the stack.
    * @param stack The stack to add the frame to.
    * @param frame The frame to add to the stack.
*/
void MCL_Stack_Add_Frame(MCL_Stack *stack, MCL_Frame *frame, uint32_t gravity);

// void MCL_Stack_Add_Textbox(MCL_Stack *stack, MCL_Textbox *textbox);

#ifdef __cplusplus
}
#endif

#endif // _mcl_stack_h_