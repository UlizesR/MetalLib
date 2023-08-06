#include "MAC/mac_gui.h"
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

@end
#endif

Mac_Button* mac_button_spb_tita(MDimensions dimensions, MTitle title, MImage image, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        return NULL;
    }

    button->dimensions = dimensions;
    button->title = title;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;

    NSString* bTitle = [NSString stringWithUTF8String:title];
    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_spb_tita:bTitle image:bImage]; // Call the method on the instance
    
    [nsButton setFrame: NSMakeRect(dimensions.x, dimensions.y, dimensions.width, dimensions.height)];
    nsButton.tag = (NSInteger)button; // Set the tag property

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);

    [nsView addSubview:nsButton];
    
    return button;
}

Mac_Button* mac_button_spb_tta(MDimensions dimensions, MTitle title, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        return NULL;
    }

    button->dimensions = dimensions;
    button->title = title;
    button->image = NULL;
    button->parent_view = parent_view;
    button->action = action;

    NSString* bTitle = [NSString stringWithUTF8String:title];

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_spb_tta:bTitle]; // Call the method on the instance

    [nsButton setFrame: NSMakeRect(dimensions.x, dimensions.y, 0, 0)];
    nsButton.tag = (NSInteger)button; // Set the tag property
    [nsButton setEnabled:YES];
    [nsButton sizeToFit];

    NSView* nsView = (__bridge NSView *)(button->parent_view->_this);
    [nsView addSubview:nsButton];

    return button;
}

Mac_Button* mac_button_spb_ita(MDimensions dimensions, MImage image, Mac_View* parent_view, ButtonAction action)
{
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    if(button == NULL) {
        return NULL;
    }

    button->dimensions = dimensions;
    button->title = NULL;
    button->image = image;
    button->parent_view = parent_view;
    button->action = action;

    NSImage* bImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:image]];
    printf("Image: %s\n", image);

    NSMac_Button* nsButton = [[NSMac_Button alloc] init];
    nsButton = [nsButton button_spb_ita:bImage]; // Call the method on the instance
    printf("button created\n");

    [nsButton setFrame: NSMakeRect(dimensions.x, dimensions.y, dimensions.width, dimensions.height)];
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
