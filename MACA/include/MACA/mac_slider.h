#ifndef mac_slider_h_
#define mac_slider_h_

#include "mac_internals.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h> 

@interface NSMac_Slider : NSSlider
@end
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Mac_Slider Mac_Slider;
typedef void (*SliderAction)(Mac_Slider*);

struct Mac_Slider
{
    MSize size;
    MPoint position;
    float value;
    float minValue;
    float maxValue;
    float increment;
    SliderAction action;
    Mac_View *parent_view;
};

/*!
    Creates a slider with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param parent_view: the view to draw the slider on
    @param action: the action to be performed when the slider is moved
*/
Mac_Slider* mac_slider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_View* parent_view, SliderAction action);

/*!
    Destroys the given slider.
    @param slider: the slider to be destroyed
*/
void destroy_slider(Mac_Slider* slider);

#ifdef __cplusplus
}
#endif

#endif // mac_slider_h_