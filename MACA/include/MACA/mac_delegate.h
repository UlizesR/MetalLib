#ifndef mac_delegate_h_
#define mac_delegate_h_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface Mac_Delegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSView *content_view;

@end

/*!
    initializes the delegate
    @return the delegate
*/
Mac_Delegate* initDelegate();
/*
    terminates the delegate/app
*/

#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
    terminates the delegate
*/
void terminateDelegate();

/*!
    runs loop for the app
*/
void runDelegate();

/*!
    checks if the delegate is initialized
    @return 1 if initialized, 0 if not
*/
int checkDelegateInit();

#ifdef __cplusplus
}
#endif

#endif // mac_delegate_h_