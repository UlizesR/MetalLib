#import "MCL/gui/sliders.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

@interface MCL_NsSlider : NSSlider
@end

@interface RectangularKnobSliderCell : NSSliderCell
@property(strong, nonatomic) NSColor *knobColor;
@property(strong, nonatomic) NSColor *trackColor;
@property(strong, nonatomic) NSColor *trackBackgroundColor;
@end

@implementation MCL_NsSlider

- (void)sliderValueChanged:(id)sender {
	NSSlider *nsSlider = (NSSlider *)sender;
	MCL_Slider *slider = (__bridge MCL_Slider *)(nsSlider.tag);

	// Calculate the new value based on the increment
	float newValue = (nsSlider.floatValue / slider->increment) * slider->increment;

	// Ensure the value is within the min and max range
	newValue = fmaxf(slider->minValue, fminf(slider->maxValue, newValue));

	// Update the slider value
	nsSlider.floatValue = newValue;
	slider->value = newValue;

	if (slider->action)
	{
		slider->action(slider->data);
	}
}

@end

@implementation RectangularKnobSliderCell

- (void)drawKnob:(NSRect)knobRect {
	// Make the knob half its original length
	NSRect rectangularKnobRect = NSMakeRect(
		knobRect.origin.x, knobRect.origin.y + knobRect.size.height * 0.1,
		knobRect.size.width, knobRect.size.height * 0.8);

	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rectangularKnobRect];
	[self.knobColor setFill]; // Use the custom color for the knob
	[path fill];
}

- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped {
	NSRect knobRect = [self knobRectFlipped:flipped];
	NSRect trackRect = NSMakeRect(rect.origin.x, knobRect.origin.y,
									rect.size.width, knobRect.size.height);

	// Draw the track background
	NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:trackRect];
	[self.trackBackgroundColor setFill];
	[backgroundPath fill];

	// Calculate the filled portion of the track based on the current value of the
	// slider
	CGFloat filledWidth = (([self floatValue] - [self minValue]) /
							([self maxValue] - [self minValue])) *
							rect.size.width;
	NSRect filledTrackRect = NSMakeRect(rect.origin.x, knobRect.origin.y,
										filledWidth, knobRect.size.height);

	// Draw the filled portion of the track
	NSBezierPath *filledPath = [NSBezierPath bezierPathWithRect:filledTrackRect];
	[self.trackColor setFill];
	[filledPath fill];
}

@end

void MCL_AddSlider(MCL_Frame *frame, MCL_Slider *slider, int x, int y, int w, int h, float minValue, float maxValue, float increment, int orientation, int style, MCL_ActionCallback action, void *data) 
{
	// check if the frame is null
	if (!frame) {
		fprintf(stderr, "Failed to add a slider! The frame is null!\n");
		return;
	}
	// set the sliders properties
	slider->x = x;
	slider->y = y;
	slider->w = w;
	slider->h = h;
	slider->minValue = minValue;
	slider->maxValue = maxValue;
	slider->increment = increment;
	slider->value = minValue;
	slider->action = action;
	slider->data = data;
	// create the ns slider
	NSRect frameRect = NSMakeRect(x, y, w, h);
	MCL_NsSlider *nsSlider = [[MCL_NsSlider alloc] initWithFrame:frameRect];
	// set the slider properties
	[nsSlider setNeedsDisplay:YES];
	// set the slider orientation
	if (orientation == MCL_SLIDER_HORIZONTAL) {
		[nsSlider setVertical:NO];
	} else if (orientation == MCL_SLIDER_VERTICAL) {
		[nsSlider setVertical:YES];
	}
	[nsSlider setMinValue:minValue];
	[nsSlider setMaxValue:maxValue];
	[nsSlider setTarget:nsSlider];
	[nsSlider setAction:@selector(sliderValueChanged:)];

	nsSlider.tag = (__bridge NSInteger)(slider);

	// get the ns view
	NSView *nsView = (__bridge NSView *)(frame->_this);
	// add the ns slider to the ns view
	[nsView addSubview:nsSlider];

	slider->_this = (__bridge void *)nsSlider;
}