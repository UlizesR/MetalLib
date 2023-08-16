#include "MIA/buttons.h"
#include "MIA/view.h"

@implementation M_NSButton

- (void)onClick:(id)sender 
{
    NSButton *nsButton = (NSButton*)sender;
    M_Button *button = (M_Button *)nsButton.tag;
    if (button && button->action) {
        button->action(button, button->data); // Pass the user data
    }
}


- (instancetype)button_spb_tita:(NSString*)title image:(NSImage*)image 
{
    M_NSButton* button = [M_NSButton buttonWithTitle:title image:image target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_spb_tta:(NSString*)title 
{
    M_NSButton* button = [M_NSButton buttonWithTitle:title target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_spb_ita:(NSImage*)image 
{
    M_NSButton* button = [M_NSButton buttonWithImage:image target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_scb_tta:(NSString*)title 
{
    M_NSButton* button = [M_NSButton checkboxWithTitle:title target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_srb_tta:(NSString*)title 
{
    M_NSButton* button = [M_NSButton radioButtonWithTitle:title target:self action:@selector(onClick:)];
    return button;
}

@end

M_Button* M_ButtonSpb1(MSize size, MPoint position, MTitle title, MImage image, M_View* parent_view, Action action, void* data)
{
    // Allocate memory for the button and check if it failed
    M_Button* button = (M_Button*)malloc(sizeof(M_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }
    // Set the button's properties
    button->size = size;
    button->position = position;
    button->title = title;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;
    button->data = data;
    // Create the NSButton
    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];
    M_NSButton* nsButton = [[M_NSButton alloc] button_spb_tita:bTitle image:bImage];
    button->_this = (__bridge void *)nsButton;

    // Set the button's frame
    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];
    // Add the NSButton to the parent view
    if (parent_view == NULL) {
        printf("Error: Parent view is NULL\n");
        return NULL;
    }
    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsButton];

    // Return the button
    return button;
}

M_Button* M_ButtontSpb2(MSize size, MPoint position, MTitle title, M_View* parent_view, Action action, void* data)
{
    // Allocate memory for the button and check if it failed
    M_Button* button = (M_Button*)malloc(sizeof(M_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }
    // Set the button's properties
    button->size = size;
    button->position = position;
    button->title = title;
    button->parent_view = parent_view;
    button->action = action;
    button->data = data;
    button->image = NULL;
    // Create the NSButton
    NSString* bTitle = [NSString stringWithUTF8String:title];
    M_NSButton* nsButton = [[M_NSButton alloc] button_spb_tta:bTitle];
    button->_this = (__bridge void *)nsButton;

    // Set the button's frame
    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    // Add the NSButton to the parent view
    if (parent_view == NULL) {
        printf("Error: Parent view is NULL\n");
        return NULL;
    }
    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsButton];

    // Return the button
    return button;
}

M_Button* M_ButtonSpb3(MSize size, MPoint position, MImage image, M_View* parent_view, Action action, void* data)
{
    // Allocate memory for the button and check if it failed
    M_Button* button = (M_Button*)malloc(sizeof(M_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }
    // Set the button's properties
    button->size = size;
    button->position = position;
    button->title = NULL;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;
    button->data = data;
    // Create the NSButton
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];
    M_NSButton* nsButton = [[M_NSButton alloc] button_spb_ita:bImage];
    button->_this = (__bridge void *)nsButton;

    // Set the button's frame
    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    // Add the NSButton to the parent view
    if (parent_view == NULL) {
        printf("Error: Parent view is NULL\n");
        return NULL;
    }
    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsButton];

    // Return the button
    return button;
}

M_Button* M_ButtonScb(MSize size, MPoint position, MTitle title, M_View* parent_view, Action action, void* data)
{
    // Allocate memory for the button and check if it failed
    M_Button* button = (M_Button*)malloc(sizeof(M_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }
    // Set the button's properties
    button->size = size;
    button->position = position;
    button->title = title;
    button->parent_view = parent_view;
    button->action = action;
    button->data = data;
    button->image = NULL;
    // Create the NSButton
    NSString* bTitle = [NSString stringWithUTF8String:title];
    M_NSButton* nsButton = [[M_NSButton alloc] button_scb_tta:bTitle];
    button->_this = (__bridge void *)nsButton;

    // Set the button's frame
    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    // Add the NSButton to the parent view
    if (parent_view == NULL) {
        printf("Error: Parent view is NULL\n");
        return NULL;
    }
    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsButton];

    // Return the button
    return button;
}

M_Button* M_ButtonSrb(MSize size, MPoint position, MTitle title, M_View* parent_view, Action action, void* data)
{
    // Allocate memory for the button and check if it failed
    M_Button* button = (M_Button*)malloc(sizeof(M_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }
    // Set the button's properties
    button->size = size;
    button->position = position;
    button->title = title;
    button->parent_view = parent_view;
    button->action = action;
    button->data = data;
    button->image = NULL;
    // Create the NSButton
    NSString* bTitle = [NSString stringWithUTF8String:title];
    M_NSButton* nsButton = [[M_NSButton alloc] button_srb_tta:bTitle];
    button->_this = (__bridge void *)nsButton;

    // Set the button's frame
    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    // Add the NSButton to the parent view
    if (parent_view == NULL) {
        printf("Error: Parent view is NULL\n");
        return NULL;
    }
    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsButton];

    // Return the button
    return button;
}

void M_HideButton(M_Button* button) {
    if (button == NULL) {
        printf("Error: Button is NULL\n");
        return;
    }

    NSButton* nsButton = (__bridge NSButton *)(button->_this);
    if (nsButton) {
        [nsButton setHidden:YES];
    } else {
        printf("Error: Could not find button with tag %d\n", button->tag);
    }
}

void M_ShowButton(M_Button* button) {
    if (button == NULL) {
        printf("Error: Button is NULL\n");
        return;
    }

    NSButton* nsButton = (__bridge NSButton *)(button->_this);
    if (nsButton) {
        [nsButton setHidden:NO];
    } else {
        printf("Error: Could not find button with tag %d\n", button->tag);
    }
}

void M_DestroyButton(M_Button* button) {
    if (button != NULL) {
        free(button);
    }
}