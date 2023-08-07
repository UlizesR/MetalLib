#ifndef mac_slider_h_
#define mac_slider_h_

#include "mac_internals.h"
#include "mac_view.h"

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
    MProperties properties;
    float value;
    float minValue;
    float maxValue;
    float increment;
    SliderAction action;
    Mac_View *parent_view;
};

Mac_Slider* mac_slider(MProperties properties, float minValue, float maxValue, float increment, Mac_View* parent_view, SliderAction action);
void destroy_slider(Mac_Slider* slider);

#ifdef __cplusplus
}
#endif

#endif // mac_slider_h_