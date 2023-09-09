#import "MCL/gui/buttons.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@interface MCL_NsButton : NSButton
@end

@implementation MCL_NsButton

- (void)onClick:(id)sender {
  NSButton *nsButton = (NSButton *)sender;
  MCL_Button *button = (MCL_Button *)nsButton.tag;
  if (button && button->action) {
    button->action(button, button->data); // Pass the user data
  }
} 

@end

void MCL_AddButton(MCL_Frame *frame, MCL_Button *button, int x, int y, int w, int h, const char *title, const char *icon, MCL_ActionCallback action, void *data) {
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
    button->icon = icon;
    button->action = action;
    button->data = data;
    // create the ns button
    NSRect buttonFrame = NSMakeRect(x, y, w, h);
    MCL_NsButton *nsButton = [[MCL_NsButton alloc] initWithFrame:buttonFrame];
    // set the ns button and its properties
    NSString *bTitle = [NSString stringWithUTF8String:title];
    if (icon)
    {
        NSImage *bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:icon]];
    }
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