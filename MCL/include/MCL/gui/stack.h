#ifndef _mcl_stack_h_
#define _mcl_stack_h_

#include "../../MCL/colors.h"
#include "../../MCL/defs.h"
#include "./sliders.h"
#include "./buttons.h"
#include "./text.h"
#include "./textbox.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

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
    * @brief adds a button to the stack.
    * @param stack The stack to add the button to.
    * @param button The button to add to the stack.
*/
void MCL_Stack_Add_Button(MCL_Stack *stack, MCL_Button *button);

/*!
    * @brief adds a slider to the stack.
    * @param stack The stack to add the slider to.
    * @param slider The slider to add to the stack.
*/
void MCL_Stack_Add_Slider(MCL_Stack *stack, MCL_Slider *slider);

/*!
    * @brief adds a text to the stack.
    * @param stack The stack to add the text to.
    * @param text The text to add to the stack.
*/
void MCL_Stack_Add_Text(MCL_Stack *stack, MCL_Text *text);

/*!
    * @brief adds a frame to the stack.
    * @param stack The stack to add the frame to.
    * @param frame The frame to add to the stack.
*/
void MCL_Stack_Add_Frame(MCL_Stack *stack, MCL_Frame *frame);

// void MCL_Stack_Add_Textbox(MCL_Stack *stack, MCL_Textbox *textbox);

#ifdef __cplusplus
}
#endif

#endif // _mcl_stack_h_