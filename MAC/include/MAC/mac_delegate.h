#ifndef MAC_DELGATE_H_
#define MAC_DELGATE_H_

#ifdef __OBJC__
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

#endif

#ifdef __cplusplus
extern "C" {
#endif

void terminateDelegate();
void runDelegate();
int checkDelegateInit();

#ifdef __cplusplus
}
#endif

#endif // MAC_DELGATE_H_