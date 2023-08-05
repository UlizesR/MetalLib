#include "MAC/mac_gui.h"
#include "MAC/mac_error.h"
#include <stdio.h>

#ifdef __OBJC__

@implementation NSMac_Button
// You can add custom implementations for the NSMac_Button here if needed.
@end

#endif

Mac_Button* createButton(Mac_View* parent_view, int width, int height, int x, int y, const char* title) {
    Mac_Button* button = (Mac_Button*)malloc(sizeof(Mac_Button));
    button->parent_view = parent_view;
    button->width = width;
    button->height = height;
    button->x = x;
    button->y = y;
    button->title = strdup(title);
  
    NSMac_Button* nsButton = [[NSMac_Button alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    [nsButton setTitle:[NSString stringWithUTF8String:title]];
  
    // // Assign the Mac_NSButton instance to the _this member of the Mac_Button struct
    // button->_this = (__bridge void *)(nsButton);

    if (parent_view) {
        Mac_NSView* nsParentView = (__bridge Mac_NSView*)parent_view->_this;
        [nsParentView addSubview:nsButton];
    }
  
    return button;
}


void destroyButton(Mac_Button* button) {
    if (button) {
        NSButton *nsButton = (__bridge NSButton*)button->delegate;
        [nsButton removeFromSuperview];
        // If you've allocated any other resources within the Mac_Button struct, make sure to free them here.
        free(button);
    }
}
