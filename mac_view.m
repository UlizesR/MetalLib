#import "mac_view.h"

@implementation Mac_View

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"Mouse down event: %@", event);
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"Key down event: %@", event);
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    return NO;
}

@end