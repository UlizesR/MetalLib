#import "MACA/mac_buttons.h"
#import "MACA/mac_view.h"
#import "MACA/mac_text.h"

#include <stdio.h>

#ifdef __OBJC__

@implementation NSMac_Button

- (void)onClick:(id)sender 
{
    NSButton *nsButton = (NSButton*)sender;
    Mac_Button *button = (Mac_Button *)nsButton.tag;
    if (button && button->action) {
        button->action(button, button->user_data); // Pass the user data
    }
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

#endif

static char MacButtonKey;

Mac_Button* MAC_ButtonRS(MSize size, MPoint position, MImage image, MTitle title,  UInt32 type, int font_size, bool isBordered, bool bordered_when_hovered, Mac_View* parent_view, ButtonAction action, void* user_data)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        printf("Memory allocation for button failed\n");
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;
    button->user_data = user_data; // Set the user_data field

    if (font_size > size.height) {
        printf("Font size is too big for the button\n");
        free(button);
        return NULL;
    }

    MSize textSize = MAC_GetTextSize(title, font_size);
    if (textSize.width > size.width || textSize.height > size.height) {
        printf("Text is too big for the button\n");
        free(button);
        return NULL;
    }

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];

    NSRect frame = NSMakeRect(position.x, position.y, size.width, size.height);
    NSMac_Button* nsButton = [[NSMac_Button alloc] initWithFrame:frame];
    button->_this = (__bridge void *)nsButton;

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
    button->_this = (__bridge void *)nsButton;

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsButton];

    return button;
}

Mac_Button* MAC_ButtonSpbTita(MSize size, MPoint position, MTitle title, MImage image, Mac_View* parent_view, ButtonAction action, void* user_data)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;
    button->user_data = user_data;

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];
    NSMac_Button* nsButton = [[NSMac_Button alloc] button_spb_tita:bTitle image:bImage];
    button->_this = (__bridge void *)nsButton;


    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsButton];

    return button;
}


Mac_Button* MAC_ButtonSpbTta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action, void* user_data)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = "";
    button->parent_view = parent_view;
    button->action = action;
    button->user_data = user_data;

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSMac_Button* nsButton = [[NSMac_Button alloc] button_spb_tta:bTitle];
    button->_this = (__bridge void *)nsButton;


    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsButton];

    return button;
}


Mac_Button* MAC_ButtonSpbIta(MSize size, MPoint position, MImage image, Mac_View* parent_view, ButtonAction action, void* user_data)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = "";
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;
    button->user_data = user_data;

    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];
    NSMac_Button* nsButton = [[NSMac_Button alloc] button_spb_ita:bImage];
    button->_this = (__bridge void *)nsButton;


    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsButton];

    return button;
}


Mac_Button* MAC_ButtonScbTta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action, void* user_data)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = "";
    button->parent_view = parent_view;
    button->action = action;
    button->user_data = user_data;
    
    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSMac_Button* nsButton = [[NSMac_Button alloc] button_scb_tta:bTitle];
    button->_this = (__bridge void *)nsButton;

    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsButton];

    return button;
}


Mac_Button* MAC_ButtonSrbTta(MSize size, MPoint position, MTitle title, Mac_View* parent_view, ButtonAction action, void* user_data)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        printf("Error: Could not allocate memory for button\n");
        return NULL;
    }

    button->size = size;
    button->position = position;
    button->title = title;
    button->image = "";
    button->parent_view = parent_view;
    button->action = action;
    button->user_data = user_data;

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSMac_Button* nsButton = [[NSMac_Button alloc] button_srb_tta:bTitle];
    button->_this = (__bridge void *)nsButton;


    [nsButton setFrame: NSMakeRect(position.x, position.y, size.width, size.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    button->tag = (int)nsButton.tag;
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsButton];

    return button;
}

void MAC_HideButton(Mac_Button* button) {
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

void MAC_ShowButton(Mac_Button* button) {
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

void MAC_DestroyButton(Mac_Button* button) {
    if (button != NULL) {
        free(button);
    }
}