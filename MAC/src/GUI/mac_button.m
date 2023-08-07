#include "MAC/mac_button.h"
#include "MAC/mac_view.h"
#include "MAC/mac_error.h"
#include <MacTypes.h>
#include <stdio.h>
#ifdef __OBJC__

@implementation NSMac_Button

- (void)onClick:(id)sender 
{
    NSButton *nsButton = (NSButton*)sender;
    NSInteger tag = nsButton.tag;
    Mac_Button *button = (Mac_Button*)tag;
    button->action(button);
}

- (instancetype)button_spb_tita:(NSString*)title image:(NSImage*)image 
{
    NSMac_Button* button = [NSMac_Button buttonWithTitle:title image:image target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_spb_tta:(NSString*)title 
{
    NSMac_Button* button = [NSMac_Button buttonWithTitle:title target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_spb_ita:(NSImage*)image 
{
    NSMac_Button* button = [NSMac_Button buttonWithImage:image target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_scb_tta:(NSString*)title 
{
    NSMac_Button* button = [NSMac_Button checkboxWithTitle:title target:self action:@selector(onClick:)];
    return button;
}

- (instancetype)button_srb_tta:(NSString*)title 
{
    NSMac_Button* button = [NSMac_Button radioButtonWithTitle:title target:self action:@selector(onClick:)];
    return button;
}

@end

@implementation CenteredButtonCell

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSAttributedString *attrTitle = [self attributedTitle];
    NSSize titleSize = [attrTitle size];
    titleFrame.origin.y = (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

@end
#endif

Mac_Button* mac_button_rs(MSize size, MPoint position, MImage image, MTitle title,  UInt32 type, int font_size, bool isBordered, bool bordered_when_hovered, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        mac_printError(MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED);
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;

    if (font_size > size.height) {
        mac_printError(MAC_ERROR_BUTTON_FONT_SMALLER_THAN_HEIGHT);
        return NULL;
    }

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];

    NSRect frame = NSMakeRect(position.x, position.y, size.width, size.height);
    NSMac_Button* nsButton = [[NSMac_Button alloc] initWithFrame:frame];
    if (bTitle)
    {
        [nsButton setFont:[NSFont systemFontOfSize:font_size]];
        [nsButton setTitle:bTitle];
        [nsButton setAlignment:NSTextAlignmentCenter];
    }
    [nsButton setBezelStyle:NSBezelStyleRegularSquare];
    [nsButton setButtonType:type];

    if (isBordered) {
        [nsButton setBordered:YES];
    } else {
        [nsButton setBordered:NO];
    }
    if (bordered_when_hovered) {
        [nsButton setShowsBorderOnlyWhileMouseInside:YES];
    } else {
        [nsButton setShowsBorderOnlyWhileMouseInside:NO];
    }
    if (bImage) {
        [nsButton setImage:bImage];
        [nsButton setImageScaling:NSImageScaleProportionallyDown];
        [nsButton setImagePosition:NSImageLeft];
    }

    [nsButton setEnabled:YES];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setTarget:nsButton];
    [nsButton setAction:@selector(onClick:)];

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);

    [nsView addSubview:nsButton];

    return button;
}


Mac_Button* mac_button_spb_tita(MSize size, MPoint position, MTitle title, MImage image, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        mac_printError(MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED);
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_spb_tita:bTitle image:bImage]; // Call the method on the instance
    
    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);

    [nsView addSubview:nsButton];
    
    return button;
}

Mac_Button* mac_button_spb_tta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        mac_printError(MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED);
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = NULL;
    button->parent_view = parent_view;
    button->action = action;

    NSString* bTitle = [NSString stringWithUTF8String:title];

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_spb_tta:bTitle]; // Call the method on the instance

    [nsButton setFrame: NSMakeRect(position.x, position.y, 0, 0)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);
    [nsView addSubview:nsButton];

    return button;
}
Mac_Button* mac_button_spb_ita(MSize size, MPoint position, MImage image, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        mac_printError(MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED);
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = NULL;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;

    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];
    printf("Image: %s\n", image);

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_spb_ita:bImage]; // Call the method on the instance
    printf("button created\n");

    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);

    [nsView addSubview:nsButton];
    
    return button;
}

Mac_Button* mac_button_scb_tta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        mac_printError(MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED);
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = NULL;
    button->parent_view = parent_view;
    button->action = action;

    NSString* bTitle = [NSString stringWithUTF8String:title];

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_scb_tta:bTitle]; // Call the method on the instance

    [nsButton setFrame: NSMakeRect(position.x, position.y, 0, 0)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);
    [nsView addSubview:nsButton];

    return button;
}

Mac_Button* mac_button_srb_tta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        mac_printError(MAC_ERROR_BUTTON_MEMORY_ALLOCATION_FAILED);
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = NULL;
    button->parent_view = parent_view;
    button->action = action;

    NSString* bTitle = [NSString stringWithUTF8String:title];

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_srb_tta:bTitle]; // Call the method on the instance

    [nsButton setFrame: NSMakeRect(position.x, position.y, 0, 0)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);
    [nsView addSubview:nsButton];

    return button;
}


void destroyButton(Mac_Button* button) {
    if (button != NULL) {
        free(button);
    }
}
