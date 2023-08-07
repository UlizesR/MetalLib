#import "MAC/mac_slider.h"

@implementation NSMac_Slider

- (void)sliderValueChanged:(id)sender {
    NSSlider *nsSlider = (NSSlider*)sender;
    Mac_Slider *slider = (__bridge Mac_Slider *)(nsSlider.tag);
    slider->value = nsSlider.floatValue;
    slider->action(slider);
}

@end

Mac_Slider* mac_slider(MProperties properties, float minValue, float maxValue, float increment, Mac_View* parent_view, SliderAction action) {
    Mac_Slider* slider = (Mac_Slider*)malloc(sizeof(Mac_Slider));
    if(slider == NULL) {
        return NULL;
    }

    slider->properties = properties;
    slider->minValue = minValue;
    slider->maxValue = maxValue;
    slider->increment = increment;
    slider->parent_view = parent_view;
    slider->action = action;

    NSMac_Slider* nsSlider = [[NSMac_Slider alloc] initWithFrame:NSMakeRect(properties.position.x, properties.position.y, properties.size.width, properties.size.height)];
    // [nsSlider setTrackFillColor:[NSColor redColor]];

    [nsSlider setMinValue:minValue];
    [nsSlider setMaxValue:maxValue];
    [nsSlider setDoubleValue:minValue]; // Initial value

    [nsSlider setTarget:nsSlider];
    [nsSlider setAction:@selector(sliderValueChanged:)];
    nsSlider.tag = (__bridge NSInteger)(slider);


    NSView* nsView = (__bridge NSView *)(slider->parent_view->_this);
    [nsView addSubview:nsSlider];

    return slider;
}

void destroy_slider(Mac_Slider* slider) {
    if (slider != NULL) {
        free(slider);
    }
}