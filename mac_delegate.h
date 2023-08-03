#ifndef MAC_DELGATE_H_
#define MAC_DELGATE_H_


#import <Cocoa/Cocoa.h>

@interface Mac_Delegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSView *content_view;

@end

/*
    initializes the delegate
*/
Mac_Delegate* initDelegate();
/*
    terminates the delegate/app
*/
void terminateDelegate();
/*
    runs the delegate/app
*/
void runDelegate();

#endif // MAC_DELGATE_H_