#import <Cocoa/Cocoa.h>
#import "mac_view.h"

@interface Mac_Delegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) Mac_View *content_view;

@end

extern Mac_Delegate* mac_delegate;