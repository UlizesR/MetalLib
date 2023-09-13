#import "MCL/gui/buttons.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@interface MCL_NsButton : NSButton
@end

@implementation MCL_NsButton

- (void)onClick:(id)sender {
    NSButton *nsButton = (NSButton *)sender;
    MCL_Button *button = (MCL_Button *)nsButton.tag;
    if (button->action) {
        button->action(button, button->data); // Pass the user data
    }
} 

@end

void MCL_AddButton(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data) {
    // check if frame is null
    if (!frame) {
        fprintf(stderr, "Failed to add text! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *nsView = (__bridge NSView *)(frame->_this);
    // set the button properties
    button->x = x;
    button->y = y;
    button->w = w;
    button->h = h;
    button->title = title;
    button->action = action;
    button->data = data;
    // create the ns button
    NSRect buttonFrame = NSMakeRect(x, y, w, h);
    MCL_NsButton *nsButton = [[MCL_NsButton alloc] initWithFrame:buttonFrame];
    // set the ns button and its properties
    NSString *bTitle = [NSString stringWithUTF8String:title];
    [nsButton setTitle:[NSString stringWithUTF8String:title]];
    [nsButton setButtonType:NSButtonTypeMomentaryPushIn];
    [nsButton setBezelStyle:NSBezelStyleRegularSquare];
    [nsButton setEnabled:YES];
    [nsButton setTag:(NSInteger)button];
    [nsButton setTarget:nsButton];
    [nsButton setAction:@selector(onClick:)];
    button->_this = (__bridge void *)nsButton;

    // add the button to the view
    [nsView addSubview:nsButton];
    [nsView setNeedsDisplay:YES];
}

void MCL_SetButtonHints(MCL_Button *button, M_Button_Style_Flags style, M_Button_Type_Flags type)
{
    // check if button is null
    if (!button) {
        fprintf(stderr, "Failed to set button hints! The button is null!\n");
        return;
    }
    // get the ns button
    NSButton *nsButton = (__bridge NSButton *)(button->_this);
    // set the button hints
    switch (style)
    {    
        case M_BUTTON_STYLE_NONE:
            break;
        case M_BUTTON_STYLE_ROUNDED:
            [nsButton setBezelStyle:NSBezelStyleRounded];
            break;
        case M_BUTTON_STYLE_REGULAR_SQUARE:
            break;
        case M_BUTTON_STYLE_DISCLOSURE:
            [nsButton setBezelStyle:NSBezelStyleDisclosure];
            break;
        case M_BUTTON_STYLE_SHADOWLESS_SQUARE:
            [nsButton setBezelStyle:NSBezelStyleShadowlessSquare];
            break;
        case M_BUTTON_STYLE_CIRCULAR:
            [nsButton setBezelStyle:NSBezelStyleCircular];
            break;
        case M_BUTTON_STYLE_TEXTURED_SQUARE:
            [nsButton setBezelStyle:NSBezelStyleTexturedSquare];
            break;
        case M_BUTTON_STYLE_HELP_BUTTON:
            [nsButton setBezelStyle:NSBezelStyleHelpButton];
            break;
        case M_BUTTON_STYLE_SMALL_SQUARE:
            [nsButton setBezelStyle:NSBezelStyleSmallSquare];
            break;
        case M_BUTTON_STYLE_TEXTURED_ROUNDED:
            [nsButton setBezelStyle:NSBezelStyleTexturedRounded];
            break;
        case M_BUTTON_STYLE_ROUND_RECT:
            [nsButton setBezelStyle:NSBezelStyleRoundRect];
            break;
        case M_BUTTON_STYLE_RECESSED:
            [nsButton setBezelStyle:NSBezelStyleRecessed];
            break;
        case M_BUTTON_STYLE_ROUNDED_DISCLOSURE:
            [nsButton setBezelStyle:NSBezelStyleRoundedDisclosure];
            break;
        case M_BUTTON_STYLE_INLINE:
            [nsButton setBezelStyle:NSBezelStyleInline];
            break;
    }
    switch(type)
    {
        case M_BUTTON_TYPE_MOMENTARY_LIGHT:
            [nsButton setButtonType:NSButtonTypeMomentaryLight];
            break;
        case M_BUTTON_TYPE_PUSH_ON_PUSH_OFF:
            [nsButton setButtonType:NSButtonTypePushOnPushOff];
            break;
        case M_BUTTON_TYPE_TOGGLE:
            [nsButton setButtonType:NSButtonTypeToggle];
            break;
        case M_BUTTON_TYPE_SWITCH:
            [nsButton setButtonType:NSButtonTypeSwitch];
            break;
        case M_BUTTON_TYPE_RADIO:
            [nsButton setButtonType:NSButtonTypeRadio];
            break;
        case M_BUTTON_TYPE_MOMENTARY_CHANGE:
            [nsButton setButtonType:NSButtonTypeMomentaryChange];
            break;
        case M_BUTTON_TYPE_ON_OFF:
            [nsButton setButtonType:NSButtonTypeOnOff];
            break;
        case M_BUTTON_TYPE_MOMENTARY_PUSH_IN:
            [nsButton setButtonType:NSButtonTypeMomentaryPushIn];
            break;
        case M_BUTTON_TYPE_ACCELERATOR:
            [nsButton setButtonType:NSButtonTypeAccelerator];
            break;
        case M_BUTTON_TYPE_MULTI_LEVEL_ACCELERATOR:
            [nsButton setButtonType:NSButtonTypeMultiLevelAccelerator];
            break;
    }
}

void MCL_AddCheckBox(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data) {
  // check if frame is null
    if (!frame) {
        fprintf(stderr, "Failed to add text! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *nsView = (__bridge NSView *)(frame->_this);
    // set the button properties
    button->x = x;
    button->y = y;
    button->w = w;
    button->h = h;
    button->title = title;
    button->action = action;
    button->data = data;
    // create the ns button
    NSRect buttonFrame = NSMakeRect(x, y, w, h);
    MCL_NsButton *nsButton = [[MCL_NsButton alloc] initWithFrame:buttonFrame];
    // set the ns button and its properties
    NSString *bTitle = [NSString stringWithUTF8String:title];
    [nsButton setTitle:[NSString stringWithUTF8String:title]];
    [nsButton setButtonType:NSButtonTypeSwitch];
    [nsButton setBezelStyle:NSBezelStyleRegularSquare];
    [nsButton setEnabled:YES];
    [nsButton setTag:(NSInteger)button];
    [nsButton setTarget:nsButton];
    [nsButton setAction:@selector(onClick:)];
    button->_this = (__bridge void *)nsButton;

    // add the button to the view
    [nsView addSubview:nsButton];
    [nsView setNeedsDisplay:YES];
}

void MCL_AddRadioButton(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, MCL_ActionCallback action, void *data)
{
    // check if frame is null
    if (!frame) {
        fprintf(stderr, "Failed to add text! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *nsView = (__bridge NSView *)(frame->_this);
    // set the button properties
    button->x = x;
    button->y = y;
    button->w = w;
    button->h = h;
    button->title = title;
    button->action = action;
    button->data = data;
    // create the ns button
    NSRect buttonFrame = NSMakeRect(x, y, w, h);
    MCL_NsButton *nsButton = [[MCL_NsButton alloc] initWithFrame:buttonFrame];
    // set the ns button and its properties
    NSString *bTitle = [NSString stringWithUTF8String:title];
    [nsButton setTitle:[NSString stringWithUTF8String:title]];
    [nsButton setButtonType:NSButtonTypeRadio];
    [nsButton setBezelStyle:NSBezelStyleRegularSquare];
    [nsButton setEnabled:YES];
    [nsButton setTag:(NSInteger)button];
    [nsButton setTarget:nsButton];
    [nsButton setAction:@selector(onClick:)];
    button->_this = (__bridge void *)nsButton;

    // add the button to the view
    [nsView addSubview:nsButton];
    [nsView setNeedsDisplay:YES];
}

void M_HideButton(MCL_Button *button) {
    // check if button is null
    if (button == NULL) {
        printf("Error: Button is NULL\n");
        return;
    }   
    // get the ns button
    NSButton *nsButton = (__bridge NSButton *)(button->_this);
    [nsButton setHidden:YES];
}

void M_ShowButton(MCL_Button *button) {
    // check if button is null
    if (button == NULL) {
        printf("Error: Button is NULL\n");
        return;
    }
    // get the ns button
    NSButton *nsButton = (__bridge NSButton *)(button->_this);
    [nsButton setHidden:NO];
}

void MCL_RemoveButton(MCL_Button *button)
{
    // check if button is null
    if (!button) {
        fprintf(stderr, "Failed to remove button! The button is null!\n");
        return;
    }
    // get the ns button
    NSButton *nsButton = (__bridge NSButton *)(button->_this);
    // remove the ns button
    [nsButton removeFromSuperview];
    button->_this = NULL;
}