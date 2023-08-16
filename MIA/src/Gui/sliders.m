#include "MIA/sliders.h"
#include "MIA/view.h"

@implementation M_NSSlider

- (void)sliderValueChanged:(id)sender {
    NSSlider *nsSlider = (NSSlider*)sender;
    M_Slider *slider = (__bridge M_Slider *)(nsSlider.tag);

    // Calculate the new value based on the increment
    float newValue = roundf(nsSlider.floatValue / slider->increment) * slider->increment;

    // Ensure the value is within the min and max range
    newValue = fmaxf(slider->minValue, fminf(slider->maxValue, newValue));

    // Update the slider value
    nsSlider.floatValue = newValue;
    slider->value = newValue;

    slider->action(slider, slider->data);
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

M_Slider* M_HSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_View* parent_view, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
    
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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];

    return slider;
}

M_Slider* M_VSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_View* parent_view, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];

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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];

    return slider;
}

M_Slider* M_HTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, int tick_num, M_View* parent_view, UInt32 tick_pos, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];

    return slider;
}

M_Slider* M_VTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, int tick_num, M_View* parent_view, UInt32 tick_pos, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];

    return slider;
}

M_Slider* M_CircularSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, int radius, M_Color track_color, M_View* parent_view, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, radius * 2, radius * 2)]; // Use the radius to set the size
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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];
    
    return slider;
}

M_Slider* M_HRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_Color background_color, M_Color knob_color, M_View* parent_view, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];

    return slider;
}

M_Slider* M_VRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_Color background_color, M_Color knob_color, M_View* parent_view, Action action, void* data)
{
    M_Slider* slider = (M_Slider*)malloc(sizeof(M_Slider));
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
    slider->data = data;

    M_NSSlider* nsSlider = [[M_NSSlider alloc] initWithFrame:NSMakeRect(position.x, position.y, size.width, size.height)];
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

    NSView* nsView = (__bridge NSView*)parent_view->_this;
    [nsView addSubview:nsSlider];

    return slider;
}


void M_DestroySlider(M_Slider* slider) {
    if (slider != NULL) {
        free(slider);
    }
}