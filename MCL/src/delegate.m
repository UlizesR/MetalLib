#include "MCL/delegate.h"
#include <stdint.h>

@implementation M_Delegate // Updated class name

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  if (globalDelegate == nil) {
    return;
  }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification 
{
  if (globalDelegate == nil) {
    return;
  }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender 
{
  if (globalDelegate == nil) {
    return NO;
  }
  return YES;
}

@end

M_Delegate *globalDelegate = nil; // Updated class name

M_Delegate *initDelegate() 
{ // Updated class name
  if (globalDelegate == nil) 
  {
    globalDelegate = [[M_Delegate alloc] init]; // Updated class name
    globalDelegate.childWindows = [NSMutableArray array]; // Initialize the child windows array
  }

  return globalDelegate;
}

void terminateDelegate() 
{
  if (globalDelegate == nil) 
  {
    printf("Error at terminateDelegate(): Delegate not initialized.\n");
    return;
  }
  [NSApp terminate:globalDelegate];
  globalDelegate = nil;
}

void runDelegate() 
{
  if (globalDelegate == nil) 
  {
    printf("Error at runDelegate(): Delegate not initialized.\n");
    return;
  }
  NSEvent *event;
  do {
    event = [NSApp nextEventMatchingMask:NSEventMaskAny
                               untilDate:[NSDate distantPast]
                                  inMode:NSDefaultRunLoopMode
                                 dequeue:YES];
    if (event) 
    {
      [NSApp sendEvent:event];
    }
  } while (event);
}

int M_Init(uint32_t flags) {
  M_Delegate *delegate = initDelegate();
  if (delegate == nil) {
    return -1;
  }

  return 0;
}

void M_Quit() {
  printf("Terminating App\n");
  terminateDelegate();
}