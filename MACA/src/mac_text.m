#include "MACA/mac_text.h"
#include "MACA/mac_defs.h"
#include "MACA/mac_view.h"

@implementation NSM_Text
@end

M_Text* M_AddText(M_View* parent_view, MPoint pos, MSize size, M_Color color, MText text, int font) {
    M_Text* macText = (M_Text*)malloc(sizeof(M_Text));
    if (macText == NULL) {
        printf("Error: failed to allocate memory for text");
        return NULL;
    }

    macText->pos = pos;
    macText->size = size;
    macText->color = color;
    macText->text = text;
    macText->font = font;
    macText->parent_view = parent_view;
    macText->text_length = strlen(text);

    if (font > size.height) {
        printf("Error: font size is smaller than text height\n");
        return NULL;
    }

    NSString *string = [NSString stringWithUTF8String:text];
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:font]};
    CGSize textSize = [string sizeWithAttributes:attributes];

    CGFloat verticalOffset = (size.height - textSize.height) / 2;
    NSM_Text* nsText = [[NSM_Text alloc] initWithFrame:NSMakeRect(pos.x, pos.y + verticalOffset, size.width, textSize.height)];
    [nsText setStringValue:string];
    [nsText setTextColor:[NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a]];
    [nsText setFont:[NSFont systemFontOfSize:font]]; // You can customize this to use a specific font
    [nsText setAlignment:NSTextAlignmentCenter]; // Center text horizontally
    [nsText setBordered:YES]; // Remove border
    [nsText setBezeled:NO]; // Remove bezel
    [nsText setDrawsBackground:NO]; // Don't draw background
    [nsText setEditable:NO]; // Make it non-editable
    [nsText setSelectable:NO]; // Make it non-selectable

    NSView* nsView = getViewFromMacView(parent_view);
    [nsView addSubview:nsText];

    macText->_this = (__bridge void *)(nsText);

    return macText;
}

// TODO: this function is not working properly
MSize M_GetTextSize(MText text, int font) {
    NSString *string = [NSString stringWithUTF8String:text];
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:font]};
    CGSize size = [string sizeWithAttributes:attributes];
    return (MSize){size.width, size.height};
}

void M_UpdateText(M_Text* text, MText newText) {
    if (text == NULL) {
        printf("Error: text is NULL\n");
        return;
    }

    NSM_Text* nsText = (__bridge NSM_Text *)(text->_this);
    [nsText setStringValue:[NSString stringWithUTF8String:newText]];

    // Update the M_Text structure if needed
    text->text = newText;
    text->text_length = strlen(newText);
}

void M_RemoveText(M_Text* text) {
    NSM_Text* nsText = (__bridge NSM_Text *)(text->_this);
    NSView* nsView = getViewFromMacView(text->parent_view);
    [nsText removeFromSuperview];
    free(text);
    [nsView setNeedsDisplay:YES];
}

void M_DestroyText(M_Text* text) {
    if (text == NULL) {
        printf("Error: text is NULL\n");
        return;
    }
    free(text);
}
