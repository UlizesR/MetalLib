#include "MAC/mac_gui.h"
#include <_types/_uint32_t.h>
#include <stdio.h>

#ifdef __OBJC__

@implementation NSMac_Button
// You can add custom implementations for the NSMac_Button here if needed.
@end

#endif

void createButton(Mac_Button* button) {
    
  
    // NSMac_Button* nsButton = [[NSMac_Button alloc] initWithFrame:NSMakeRect(x, y, width, height)];
    // [nsButton setTitle:[NSString stringWithUTF8String:title]];

    // // Set the button type
    // [nsButton setButtonType:type];

    // if (parent_view) {
    //     Mac_NSView* nsParentView = (__bridge Mac_NSView*)parent_view->_this;
    //     [nsParentView addSubview:nsButton];
    // }
  
}

// void destroyButton(Mac_Button* button) {
//     if (button) {
//         NSButton *nsButton = (__bridge NSButton*)button->delegate;
//         [nsButton removeFromSuperview];
//         // If you've allocated any other resources within the Mac_Button struct, make sure to free them here.
//         free(button);
//     }
// }
