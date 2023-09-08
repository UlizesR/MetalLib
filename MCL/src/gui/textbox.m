#import "MCL/gui/textbox.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@implementation tbdelegate

- (instancetype)initWithTextField:(NSTextView *)textField {
  self = [super init];
  if (self) {
    _text = [NSMutableString string];
    _textField = textField; 
  }
  return self;
}

- (void)textDidChange:(NSNotification *)notification {
  NSTextView *textView = [notification object];
  [self.text setString:[textView string]];
  NSLog(@"Text value: %@", self.text);
}

@end

void MCL_AddTextBox(MCL_Frame *frame, int x, int y, int width, int height, const char *text, const char *font, int font_size, MCL_Color bg_color, MCL_Color text_color) {
  // check if frame is null
  if (!frame) {
    fprintf(stderr, "Failed to add textbox! The frame is null!\n");
    return;
  }
  // get the ns view
  NSView *nsView = (__bridge NSView *)(frame->_this);

  // create the text view 
  NSRect textViewFrame = NSMakeRect(0, 0, width, height);
  NSTextView *textView = [[NSTextView alloc] initWithFrame:textViewFrame];
  [textView setString:[NSString stringWithUTF8String:text]];
  [textView setTextColor:[NSColor colorWithCalibratedRed:text_color.r
                                                   green:text_color.g
                                                    blue:text_color.b
                                                   alpha:text_color.a]];
  [textView setBackgroundColor:[NSColor colorWithCalibratedRed:bg_color.r
                                                         green:bg_color.g
                                                          blue:bg_color.b
                                                         alpha:bg_color.a]];
  [textView setEditable:YES];
  [textView setSelectable:YES];
  [textView setFont:[NSFont fontWithName:[NSString stringWithUTF8String:font]
                                    size:font_size]];
  [textView setHorizontallyResizable:NO];
  [textView setVerticallyResizable:YES];
  [textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  // create the scroll view
  NSRect scrollViewFrame = NSMakeRect(x, y, width, height);
  NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollViewFrame];
  [scrollView setDocumentView:textView];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setAutohidesScrollers:YES];

  // add the scroll view to the view
  [nsView addSubview:scrollView];
  [nsView setNeedsDisplay:YES];

  // set the text value
  tbdelegate *delegate = [[tbdelegate alloc] initWithTextField:textView];
  [textView setDelegate:delegate];
}
