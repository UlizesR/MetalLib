#import "MCL/gui/textbox.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@implementation tbdelegate

- (id)initWithTextField:(NSTextView *)textField textBox:(MCL_TextBox *)textBox 
{
    self = [super init];
    if (self) {
        _text = [NSMutableString string];
        _textField = textField; 
    }
    return self;
}

- (void)textDidChange:(NSNotification *)notification 
{
    NSTextView *textView = [notification object];
    [self.text setString:[textView string]];
}

- (void)clearText
{
    // set the selected range to the whole text
    [self.textField setSelectedRange:NSMakeRange(0, [[self.textField string] length])];
    // delete the text
    [self.textField delete:nil];
    // set the string to empty
    [self.textField setString:@""];
}

- (NSString *)getText
{
    return self.text;
}
@end

void MCL_AddTextBox(MCL_Frame *frame, MCL_TextBox *textbox, int x, int y, int width, int height, const char* text, const char* font, int font_size, MCL_Color bg_color, MCL_Color text_color) 
{
    // check if frame is null
    if (!frame) {
        fprintf(stderr, "Failed to add textbox! The frame is null!\n");
        return;
    }
    // set the textbox properties
    textbox->x = x;
    textbox->y = y;
    textbox->width = width;
    textbox->height = height;
    textbox->text = text;
    textbox->font = font;
    textbox->font_size = font_size;
    textbox->bg_color = bg_color;
    textbox->text_color = text_color;
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
    [textView setRichText:NO];
    [textView setDrawsBackground:YES];
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
    tbdelegate *delegate = [[tbdelegate alloc] initWithTextField:textView textBox:textbox];
    [textView setDelegate:delegate];
    textbox->_this = (__bridge void *)(textView);
}

void MCL_ClearTextBox(MCL_TextBox *textbox) {
  // check if the textbox is null
  if (!textbox) {
    fprintf(stderr, "Failed to clear textbox! The textbox is null!\n");
    return;
  }
  // get the text view
  NSTextView *textView = (__bridge NSTextView *)(textbox->_this);
  // get the delegate object
  tbdelegate *delegate = (tbdelegate *)[textView delegate];
  // clear the text view
  [delegate clearText];
}

void MCL_GetCurrentText(MCL_TextBox *textbox)
{
    // check if the textbox is null
    if (!textbox) {
        fprintf(stderr, "Failed to get the current text! The textbox is null!\n");
        return;
    }
    // get the text view
    NSTextView *textView = (__bridge NSTextView *)(textbox->_this);
    // get the delegate object
    tbdelegate *delegate = (tbdelegate *)[textView delegate];
    // get the text
    NSString *text = [delegate getText];
    // set the text
    textbox->text = [text UTF8String];
}

void MCL_TBChangeFontSize(MCL_TextBox *textbox, int font_size)
{
    // check if the textbox is null
    if (!textbox) {
        fprintf(stderr, "Failed to change the font size! The textbox is null!\n");
        return;
    }
    // get the text view
    NSTextView *textView = (__bridge NSTextView *)(textbox->_this);
    // change the font size
    textbox->font_size = font_size;
    [textView setFont:[NSFont fontWithName:[NSString stringWithUTF8String:textbox->font]
                                        size:font_size]];
    // [textView setNeedsDisplay:YES];
}

void MCL_TBChangeFont(MCL_TextBox *textbox, const char *font)
{
    // check if the textbox is null
    if (!textbox) {
        fprintf(stderr, "Failed to change the font! The textbox is null!\n");
        return;
    }
    // get the text view
    NSTextView *textView = (__bridge NSTextView *)(textbox->_this);
    // change the font
    textbox->font = font;
    [textView setFont:[NSFont fontWithName:[NSString stringWithUTF8String:font]
                                        size:textbox->font_size]];
    // [textView setNeedsDisplay:YES];
}