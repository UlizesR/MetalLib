#import "MCL/gui/textbox.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@implementation tbdelegate

- (instancetype)initWithTextField:(NSTextField *)textField {
  self = [super init];
  if (self) {
    _text = [NSMutableString string];
    _textField = textField;
  }
  return self;
}

- (void)controlTextDidChange:(NSNotification *)notification {
  NSTextField *textField = [notification object];
  [self.text setString:[textField stringValue]];
  NSLog(@"Text value: %@", self.text);
}

@end

void MCL_AddTextBox(MCL_Frame *frame, MCL_TextBox *textbox) 
{
  // check if frame is null
  if (!frame) {
    fprintf(stderr, "Failed to add textbox! The frame is null!\n");
    return;
  }
  // get the ns view
  NSView *nsView = (__bridge NSView *)(frame->_this);

  // create the text field
  NSRect textFieldFrame = NSMakeRect(0, 0, textbox->width, textbox->height);
  NSTextField *textField = [[NSTextField alloc] initWithFrame:textFieldFrame];
  [textField setStringValue:[NSString stringWithUTF8String:textbox->text]];
  [textField
      setTextColor:[NSColor colorWithCalibratedRed:textbox->text_color.r
                                             green:textbox->text_color.g
                                              blue:textbox->text_color.b
                                             alpha:textbox->text_color.a]];
  [textField setDrawsBackground:NO];
  [textField setBordered:NO];
  [textField setEditable:YES];
  [textField setSelectable:YES];
  [textField setLineBreakMode:NSLineBreakByWordWrapping]; // set the line break mode

  // create the scroll view
  NSRect scrollViewFrame = NSMakeRect(textbox->x, textbox->y, textbox->width, textbox->height);
  NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollViewFrame];
  [scrollView setDocumentView:textField];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setAutohidesScrollers:YES];

  // add the scroll view to the view
  [nsView addSubview:scrollView];
  [nsView setNeedsDisplay:YES];

  // set the _this pointer
  textbox->_this = (__bridge void *)(scrollView);

  // set the text value
  tbdelegate *delegate = [[tbdelegate alloc] initWithTextField:textField];
  [textField setTarget:delegate];
  [textField setAction:@selector(textDidChange:)];
  [textField setDelegate:delegate];

  textbox->text = [delegate.text UTF8String];
}
