#import "MCL/gui/text.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

void MCL_AddText(MCL_Frame *frame, MCL_Text *sText, int x, int y, const char *text, const char *font, int font_size, MCL_Color color)
{
    // check if frame is null
    if (!frame) {
        fprintf(stderr, "Failed to add text! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *nsView = (__bridge NSView *)(frame->_this);

    // create the text
    NSString *textString = [NSString stringWithUTF8String:text];
    NSRect frameRect = NSMakeRect(x, y, 0, 0);
    NSTextField *nsText = [[NSTextField alloc] initWithFrame:frameRect];
    NSColor *textColor = [NSColor colorWithCalibratedRed:color.r
                                                    green:color.g
                                                     blue:color.b
                                                    alpha:color.a];
    // set the text
    [nsText setStringValue:textString];
    [nsText setTextColor:textColor];
    NSString *textFontName = [NSString stringWithUTF8String:font];
    NSFont *textFont = [NSFont fontWithName:textFontName size:font_size];
    [nsText setFont:textFont];
    [nsText sizeToFit];
    // set the text's properties
    [nsText setEditable:NO];
    [nsText setBordered:NO];
    [nsText setDrawsBackground:NO];

    // check if sText is not null
    if (sText) 
    {
        // set the text's properties
        sText->_this = (__bridge void *)(nsText);
        sText->text = text;
        sText->font = font;
        sText->font_size = font_size;
        sText->color = color;
    }

    // add the text to the view
    [nsView addSubview:nsText];
    [nsView setNeedsDisplay:YES];
}

void MCL_RemoveText(MCL_Frame *frame, MCL_Text *sText)
{
    // check if frame is null
    if (!frame) {
        fprintf(stderr, "Failed to remove text! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *nsView = (__bridge NSView *)(frame->_this);

    // check if sText is null
    if (!sText) {
        fprintf(stderr, "Failed to remove text! The text is null!\n");
        return;
    }
    // get the ns text
    NSTextField *nsText = (__bridge NSTextField *)(sText->_this);

    // remove the text from the view
    [nsText removeFromSuperview];
    [nsView setNeedsDisplay:YES];
}

MCL_Text_S MCL_GetTextSize(const char *text, const char *font, int font_size) {
  NSString *nsText = [NSString stringWithUTF8String:text];
  NSString *nsFont = [NSString stringWithUTF8String:font];
  NSDictionary *attributes = @{NSFontAttributeName : [NSFont fontWithName:nsFont size:font_size]};
  NSSize size = [nsText sizeWithAttributes:attributes];
  MCL_Text_S textSize = {size.width, size.height};
  return textSize;
}

void MCL_GetAvailableFonts()
{
    NSArray *fontFamilies = [NSFontManager sharedFontManager].availableFontFamilies;
    for (NSString *fontFamily in fontFamilies) {
        printf("%s\n", [fontFamily UTF8String]);
    }
}