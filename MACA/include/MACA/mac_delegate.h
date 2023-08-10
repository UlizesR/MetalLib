#ifndef mac_delegate_h_
#define mac_delegate_h_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface Mac_Delegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSWindow *mainWindow;
@property (nonatomic, strong) NSView* mainWindowContentView;
@property (strong) NSMutableArray<NSWindow *> *childWindows;

@end

/*!
    initializes the delegate for the entire app
    @return the delegate
*/
Mac_Delegate* initDelegate();

extern Mac_Delegate* globalDelegate;

#endif

#ifdef __cplusplus
extern "C" {
#endif


/*!
    The run loop for the app
*/
void runDelegate();

/*
    Terminates the delegate
*/
void terminateDelegate();

#ifdef __cplusplus
}
#endif

#endif // mac_delegate_h_