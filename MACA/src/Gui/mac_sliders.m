#import "MACA/mac_sliders.h"
#include <AppKit/AppKit.h>
#import "MACA/mac_view.h"

@implementation NSMac_Slider

- (void)sliderValueChanged:(id)sender {
    NSSlider *nsSlider = (NSSlider*)sender;
    Mac_Slider *slider = (__bridge Mac_Slider *)(nsSlider.tag);
    slider->value = nsSlider.floatValue;
    slider->action(slider, slider->user_data);
    [nsSlider setNeedsDisplay:YES];
}

@end

@implementation RectangularKnobSliderCell

- (void)drawKnob:(NSRect)knobRect {
    // Make the knob half its original length
    NSRect rectangularKnobRect = NSMakeRect(knobRect.origin.x, knobRect.origin.y + knobRect.size.height * 0.1, knobRect.size.width, knobRect.size.height * 0.8);

    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rectangularKnobRect];
    [self.knobColor setFill]; // Use the custom color for the knob
    [path fill];
}

- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped {
    NSRect knobRect = [self knobRectFlipped:flipped];
    NSRect trackRect = NSMakeRect(rect.origin.x, knobRect.origin.y, rect.size.width, knobRect.size.height);

    // Draw the track background
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:trackRect];
    [self.trackBackgroundColor setFill];
    [backgroundPath fill];

    // Calculate the filled portion of the track based on the current value of the slider
    CGFloat filledWidth = (([self floatValue] - [self minValue]) / ([self maxValue] - [self minValue])) * rect.size.width;
    NSRect filledTrackRect = NSMakeRect(rect.origin.x, knobRect.origin.y, filledWidth, knobRect.size.height);

    // Draw the filled portion of the track
    NSBezierPath *filledPath = [NSBezierPath bezierPathWithRect:filledTrackRect];
    [self.trackColor setFill];
    [filledPath fill];
}

@end

Mac_Slider* MAC_HSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = size;
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
    
    [nsSlider setNeedsDisplay:YES];
    [nsSlider setVertical:NO];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];

    NSColor *color = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    [nsSlider setTrackFillColor:color]; 

    [nsSlider setContinuous:YES];

    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];

    return slider;
}

Mac_Slider* MAC_VSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = size;
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];

    [nsSlider setVertical:YES];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    NSColor *color = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    [nsSlider setTrackFillColor:color];

    [nsSlider setContinuous:YES];

    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];

    return slider;
}

Mac_Slider* MAC_HTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, int tick_num, Mac_View* parent_view, UInt32 tick_pos, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = size;
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
    [nsSlider setVertical:NO];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    [nsSlider setNumberOfTickMarks:tick_num];
    [nsSlider setTickMarkPosition:tick_pos]; // Set the tick mark position as needed

    NSColor *color = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    [nsSlider setTrackFillColor:color];
    [nsSlider setContinuous:YES];
    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];

    return slider;
}

Mac_Slider* MAC_VTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, int tick_num, Mac_View* parent_view, UInt32 tick_pos, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = size;
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
    [nsSlider setVertical:YES];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    [nsSlider setNumberOfTickMarks:tick_num];
    [nsSlider setTickMarkPosition:tick_pos]; // Set the tick mark position as needed

    NSColor *color = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    [nsSlider setTrackFillColor:color];
    [nsSlider setContinuous:YES];
    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];

    return slider;
}

Mac_Slider* MAC_CircularSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, int radius, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = (MSize){radius * 2, radius * 2}; // Use the radius to set the size
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, radius * 2, radius * 2)]; // Use the radius to set the size
    [nsSlider setSliderType:NSSliderTypeCircular];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    // [nsSlider setIncrement:increment];
    NSColor *color = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    [nsSlider setTrackFillColor:color];
    [nsSlider setContinuous:YES];
    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];
    
    return slider;
}

Mac_Slider* MAC_HRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_Color background_color, Mac_Color knob_color, Mac_View* parent_view, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = size;
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
    RectangularKnobSliderCell *customCell = [[RectangularKnobSliderCell alloc] init];
    NSColor *trackColor = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    NSColor *bgColor = [NSColor colorWithRed:background_color.r green:background_color.g blue:background_color.b alpha:background_color.a];
    NSColor *knobColor = [NSColor colorWithRed:knob_color.r green:knob_color.g blue:knob_color.b alpha:knob_color.a];
    customCell.trackColor = trackColor; // Set the track color
    customCell.knobColor = knobColor; // Set the knob color
    [nsSlider setCell:customCell];
    // [nsSlider setWantsLayer:YES];
    // [nsSlider.layer setBackgroundColor:bgColor.CGColor]; // Set the track background color

    [nsSlider setVertical:NO];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    [nsSlider setContinuous:YES];
    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];
    [nsSlider setNeedsDisplay:YES];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];

    return slider;
}

Mac_Slider* MAC_VRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_Color background_color, Mac_Color knob_color, Mac_View* parent_view, SliderAction action, void* user_data)
{
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL)
    {
        printf("Error: failed to allocate memory for slider");
        return NULL;
    }

    slider->size = size;
    slider->position = position;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->action = action;
    slider->user_data = user_data;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
    RectangularKnobSliderCell *customCell = [[RectangularKnobSliderCell alloc] init];
    NSColor *trackColor = [NSColor colorWithRed:track_color.r green:track_color.g blue:track_color.b alpha:track_color.a];
    NSColor *bgColor = [NSColor colorWithRed:background_color.r green:background_color.g blue:background_color.b alpha:background_color.a];
    NSColor *knobColor = [NSColor colorWithRed:knob_color.r green:knob_color.g blue:knob_color.b alpha:knob_color.a];
    customCell.trackColor = trackColor; // Set the track color
    customCell.knobColor = knobColor; // Set the knob color
    [nsSlider setCell:customCell];
    [nsSlider setWantsLayer:YES];
    [nsSlider.layer setBackgroundColor:bgColor.CGColor]; // Set the track background color

    [nsSlider setVertical:YES];
    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    [nsSlider setContinuous:YES];
    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];
    [nsSlider setNeedsDisplay:YES];

    nsSlider.tag = (__bridge NSInteger)(slider);
    slider->tag = (int)nsSlider.tag;

    NSView* nsView = NULL;
    switch (parent_view->type) {
        case MAC_VIEW_TYPE_NORMAL:
            nsView = (__bridge Mac_NSView_Normal *)(parent_view->view.n_view._this);
            break;
        case MAC_VIEW_TYPE_CORE_G:
            nsView = (__bridge Mac_NSView_Core_G *)(parent_view->view.r_view._this);
            break;
        case MAC_VIEW_TYPE_METAL:
            nsView = (__bridge Mac_NSView_Metal *)(parent_view->view.m_view._this);
            break;
        default:
            free(slider); // Free the allocated memory if the view type is unknown
            printf("Error: Unknown view type\n");
            return NULL;
    }
    [nsView addSubview:nsSlider];

    return slider;
}


void MAC_DestroySlider(Mac_Slider* slider) {
    if (slider != NULL) {
        free(slider);
    }
}