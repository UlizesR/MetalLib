#import "MCL/gui/stack.h"
#include <AppKit/AppKit.h>
#import "MCL/gui/buttons.h"
#import "MCL/gui/sliders.h"
#import "MCL/gui/text.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

void MCL_VStack(MCL_Frame *frame, MCL_Stack *stack, int x, int y, int width, int height, int spacing) {
    // check if frame is null
    if (frame == NULL) {
        fprintf(stderr, "Failed to create VStack, frame is null\n");
        return;
    }
    // set the properties of the stack
    stack->x = x;
    stack->y = y;
    stack->width = width;
    stack->height = height;
    stack->spacing = spacing;
    // create the stack view
    NSStackView *stackView = [[NSStackView alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    // set the stack view properties
    [stackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
    [stackView setAlignment:NSLayoutAttributeCenterX];
    [stackView setDistribution:NSStackViewDistributionFillProportionally];
    [stackView setSpacing:spacing];
    // add the stack view to the frame
    // get the nsview of the frame
    NSView *frameView = (NSView *)frame->_this;
    // add the stack view to the frame
    [frameView addSubview:stackView];
    [frameView setNeedsDisplay:YES];
    // set the stack view to the stack
    stack->_this = (void *)stackView;
}

void MCL_HStack(MCL_Frame *frame, MCL_Stack *stack, int x, int y, int width, int height, int spacing)
{
    // check if frame is null
    if (frame == NULL) {
        fprintf(stderr, "Failed to create HStack, frame is null\n");
        return;
    }
    // set the properties of the stack
    stack->x = x;
    stack->y = y;
    stack->width = width;
    stack->height = height;
    stack->spacing = spacing;
    // create the stack view
    NSStackView *stackView = [[NSStackView alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    // set the stack view properties
    [stackView setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [stackView setAlignment:NSLayoutAttributeLastBaseline];
    // [stackView setDistribution:NSStackViewDistributionEqualSpacing];
    [stackView setSpacing:spacing];
    [stackView setEdgeInsets:NSEdgeInsetsMake(spacing, spacing, spacing, spacing)];
    // add the stack view to the frame
    // get the nsview of the frame
    NSView *frameView = (NSView *)frame->_this;
    // add the stack view to the frame
    [frameView addSubview:stackView];
    [frameView setNeedsDisplay:YES];
    // set the stack view to the stack
    stack->_this = (void *)stackView;
}

void MCL_Stack_Add_Button(MCL_Stack *stack, MCL_Button *button)
{
    // check if stack is null
    if (stack == NULL) {
        fprintf(stderr, "Failed to add button to stack, stack is null\n");
        return;
    }
    // check if button is null
    if (button == NULL) {
        fprintf(stderr, "Failed to add button to stack, button is null\n");
        return;
    }
    // get the stack view
    NSStackView *stackView = (NSStackView *)stack->_this;
    // get the button view
    NSButton *buttonView = (NSButton *)button->_this;
    [buttonView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [buttonView setFrameSize:NSMakeSize(button->w, button->h)];
    // add the button to the stack view
    [stackView addView:buttonView inGravity:NSStackViewGravityLeading];
    // update the frame
    [stackView setNeedsDisplay:YES];
    stack->count++;
}

void MCL_Stack_Add_Slider(MCL_Stack *stack, MCL_Slider *slider)
{

}

void MCL_Stack_Add_Text(MCL_Stack *stack, MCL_Text *text)
{

}

void MCL_Stack_Add_Frame(MCL_Stack *stack, MCL_Frame *frame)
{

}