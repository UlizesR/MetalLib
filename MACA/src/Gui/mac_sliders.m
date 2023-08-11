#import "MACA/mac_sliders.h"
#import "MACA/mac_view.h"

@implementation NSMac_Slider

- (void)sliderValueChanged:(id)sender {
    NSSlider *nsSlider = (NSSlider*)sender;
    Mac_Slider *slider = (__bridge Mac_Slider *)(nsSlider.tag);
    slider->value = nsSlider.floatValue;
    slider->action(slider, slider->user_data);
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


Mac_Slider* MAC_RectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data)
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


void MAC_DestroySlider(Mac_Slider* slider) {
    if (slider != NULL) {
        free(slider);
    }
}