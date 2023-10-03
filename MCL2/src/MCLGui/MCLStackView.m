#import "MCL2/MCLGui/MCLStackView.h"
#import "MCL2/MCLGui/MCLButtons.h"

#import <Cocoa/Cocoa.h>
#include <stdint.h>

void MCL_VStack(MCL_View *view, MCL_Stack *stack, int x, int y, int width, int height, int spacing)
{
    // check if frame is null
    if (view == NULL) {
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
    [stackView setSpacing:spacing];
    [stackView setEdgeInsets:NSEdgeInsetsMake(spacing, spacing, spacing, spacing)];
    // add the stack view to the frame
    // get the nsview of the frame
    NSView *nsView = (NSView *)view->_this;
    // add the stack view to the frame
    [nsView addSubview:stackView];
    [nsView setNeedsDisplay:YES];
    // set the stack view to the stack
    stack->_this = (void *)stackView;
}

void MCL_HStack(MCL_View *view, MCL_Stack *stack, int x, int y, int width, int height, int spacing)
{
    // check if frame is null
    if (view == NULL) {
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
    [stackView setSpacing:spacing];
    [stackView setEdgeInsets:NSEdgeInsetsMake(spacing, spacing, spacing, spacing)];
    // add the stack view to the frame
    // get the nsview of the frame
    NSView *nsView = (NSView *)view->_this;
    // add the stack view to the frame
    [nsView addSubview:stackView];
    [nsView setNeedsDisplay:YES];
    // set the stack view to the stack
    stack->_this = (void *)stackView;
}

void MCL_StackHints(MCL_Stack *stack, uint32_t distribution, uint32_t alignment) 
{
    // check if the stack is null
    if (stack == NULL) {
        fprintf(stderr, "Failed to set the stack hints! The stack is null!\n");
        return;
    }
    // get the stack view
    NSStackView *stackView = (NSStackView *)stack->_this;
    // check the distribution flags
    if (distribution & MCL_StackDistribution_EqualSpacing) {
        [stackView setDistribution:NSStackViewDistributionEqualSpacing];
    }
    if (distribution & MCL_StackDistribution_EqualCentering) {
        [stackView setDistribution:NSStackViewDistributionEqualCentering];
    }
    if (distribution & MCL_StackDistribution_Fill) {
        [stackView setDistribution:NSStackViewDistributionFill];
    }
    if (distribution & MCL_StackDistribution_FillEqually) {
        [stackView setDistribution:NSStackViewDistributionFillEqually];
    }
    if (distribution & MCL_StackDistribution_FillProportionally) {
        [stackView setDistribution:NSStackViewDistributionFillProportionally];
    }
    if (distribution & MCL_StackDistribution_GravityAreas) {
        [stackView setDistribution:NSStackViewDistributionGravityAreas];
    }
    // check the alignment flags
    if (alignment & MCL_StackAlignment_CenterX) {
        [stackView setAlignment:NSLayoutAttributeCenterX];
    }
    if (alignment & MCL_StackAlignment_CenterY) {
        [stackView setAlignment:NSLayoutAttributeCenterY];
    }
    if (alignment & MCL_StackAlignment_Top) {
        [stackView setAlignment:NSLayoutAttributeTop];
    }
    if (alignment & MCL_StackAlignment_Bottom) {
        [stackView setAlignment:NSLayoutAttributeBottom];
    }
    if (alignment & MCL_StackAlignment_Left) {
        [stackView setAlignment:NSLayoutAttributeLeft];
    }
    if (alignment & MCL_StackAlignment_Right) {
        [stackView setAlignment:NSLayoutAttributeRight];
    }
    if (alignment & MCL_StackAlignment_Leading) {
        [stackView setAlignment:NSLayoutAttributeLeading];
    }
    if (alignment & MCL_StackAlignment_Trailing) {
        [stackView setAlignment:NSLayoutAttributeTrailing];
    }
    if (alignment & MCL_StackAlignment_FirstBaseline) {
        [stackView setAlignment:NSLayoutAttributeFirstBaseline];
    }
    if (alignment & MCL_StackAlignment_LastBaseline) {
        [stackView setAlignment:NSLayoutAttributeLastBaseline];
    }
    // update the stack view
    [stackView setNeedsDisplay:YES];
}

void MCL_StackSetInsets(MCL_Stack *stack, int top, int left, int bottom, int right) 
{
    // check if the stack is null
    if (stack == NULL) {
        fprintf(stderr, "Failed to set the stack insets! The stack is null!\n");
        return;
    }
    // get the stack view
    NSStackView *stackView = (NSStackView *)stack->_this;
    // set the stack view insets
    [stackView setEdgeInsets:NSEdgeInsetsMake(top, left, bottom, right)];
    // update the stack view
    [stackView setNeedsDisplay:YES];
}

void MCL_Stack_Add_Button(MCL_Stack *stack, MCL_Button *button, uint32_t gravity) 
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

    [buttonView setFrameSize:NSMakeSize(button->w, button->h)];
    // check the gravity flags
    if (gravity & MCL_StackGravity_Top) {
        [stackView addView:buttonView inGravity:NSStackViewGravityTop];
    }
    if (gravity & MCL_StackGravity_Bottom) {
        [stackView addView:buttonView inGravity:NSStackViewGravityBottom];
    }
    if (gravity & MCL_StackGravity_Center) {
        [stackView addView:buttonView inGravity:NSStackViewGravityCenter];
    }
    if (gravity & MCL_StackGravity_Trailing) {
        [stackView addView:buttonView inGravity:NSStackViewGravityTrailing];
    }
    if (gravity & MCL_StackGravity_Leading) {
        [stackView addView:buttonView inGravity:NSStackViewGravityLeading];
    }

    [stackView addArrangedSubview:buttonView];

    // update the frame
    [stackView setNeedsDisplay:YES];
    stack->count++;
}