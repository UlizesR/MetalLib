#ifndef mac_sliders_h_
#define mac_sliders_h_

#include "MACA/mac_colors.h"
#include "mac_colors.h"
#include "mac_defs.h"

#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h> 

@interface NSMac_Slider : NSSlider
@end

@interface RectangularKnobSliderCell : NSSliderCell
@property (strong, nonatomic) NSColor *knobColor;
@property (strong, nonatomic) NSColor *trackColor;
@property (strong, nonatomic) NSColor *trackBackgroundColor;
@end

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Mac_Slider Mac_Slider;
typedef void (*SliderAction)(Mac_Slider*, void* user_data);

typedef enum {
    MAC_SLIDER_TICK_POSITION_ABOVE = 0,
    MAC_SLIDER_TICK_POSITION_BELOW = 1,
} Mac_Slider_Tick_Position;

typedef enum {
    MAC_SLIDER_TYPE_HORIZONTAL = 0,
    MAC_SLIDER_TYPE_VERTICAL = 1,
} Mac_Slider_Orientation;

typedef enum {
    MAC_SLIDER_STYLE_CIRCULAR = 0,
    MAC_SLIDER_STYLE_RECTANGULAR = 1,
} Mac_Slider_Style;

struct Mac_Slider
{
    MSize size;
    MPoint position;
    float value;
    float minValue;
    float maxValue;
    float increment;
    int tag;
    SliderAction action;
    void* user_data;
    Mac_View *parent_view;
};

/*!
    Creates a horizontal slider with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param parent_view: the view to draw the slider on
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_HSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data);

/*!
    Creates a vertical slider with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param parent_view: the view to draw the slider on
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_VSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data);

/*!
    Creates a Horizontal slider with ticks with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param tick_num: the number of ticks on the slider
    @param parent_view: the view to draw the slider on
    @param tick_pos: the position of the ticks
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_HTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, int tick_num, Mac_View* parent_view, UInt32 tick_pos, SliderAction action, void* user_data);

/*!
    Creates a Vertical slider with ticks with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param tick_num: the number of ticks on the slider
    @param parent_view: the view to draw the slider on
    @param tick_pos: the position of the ticks
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_VTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, int tick_num, Mac_View* parent_view, UInt32 tick_pos, SliderAction action, void* user_data);

/*!
    Creates a circular slider with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param parent_view: the view to draw the slider on
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_CircularSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, int radius, Mac_Color track_color, Mac_View* parent_view, SliderAction action, void* user_data);

/*!
    Creates a rectangular slider with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param background_color: the color of the slider's background
    @param parent_view: the view to draw the slider on
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_HRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_Color background_color, Mac_Color knob_color, Mac_View* parent_view, SliderAction action, void* user_data);

/*!
    Creates a rectangular slider with the given parameters.
    @param size: the size of the slider
    @param position: the position of the slider
    @param minValue: the minimum value of the slider
    @param maxValue: the maximum value of the slider
    @param increment: the increment of the slider
    @param track_color: the color of the slider's track
    @param background_color: the color of the slider's background
    @param parent_view: the view to draw the slider on
    @param action: the action to be performed when the slider is moved
    @param user_data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
Mac_Slider* MAC_VRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, Mac_Color track_color, Mac_Color background_color, Mac_Color knob_color, Mac_View* parent_view, SliderAction action, void* user_data);

/*!
    Destroys the given slider.
    @param slider: the slider to be destroyed
*/
void MAC_DestroySlider(Mac_Slider* slider);

#ifdef __cplusplus
}
#endif

#endif // mac_sliders_h_