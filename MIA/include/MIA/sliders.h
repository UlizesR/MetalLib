#ifndef mac_sliders_h_
#define mac_sliders_h_

#include "colors.h"
#include "defs.h"
#include "internals.h"

#include <MacTypes.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h> 

@interface M_NSSlider : NSSlider
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


typedef enum {
    M_SLIDER_TICK_POSITION_ABOVE = 0,
    M_SLIDER_TICK_POSITION_BELOW = 1,
} M_Slider_Tick_Position;

typedef enum {
    M_SLIDER_TYPE_HORIZONTAL = 0,
    M_SLIDER_TYPE_VERTICAL = 1,
} M_Slider_Orientation;

typedef enum {
    M_SLIDER_STYLE_CIRCULAR = 0,
    M_SLIDER_STYLE_RECTANGULAR = 1,
} M_Slider_Style;

typedef struct M_Slider
{
    MSize size;
    MPoint position;
    float value;
    float minValue;
    float maxValue;
    float increment;
    int tag;
    Action action;
    void* data;
    M_View *parent_view;
} M_Slider;

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_HSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_View* parent_view, Action action, void* data);

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_VSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_View* parent_view, Action action, void* data);

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_HTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, int tick_num, M_View* parent_view, UInt32 tick_pos, Action action, void* data);

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_VTickSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, int tick_num, M_View* parent_view, UInt32 tick_pos, Action action, void* data);

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_CircularSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, int radius, M_Color track_color, M_View* parent_view, Action action, void* data);

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_HRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_Color background_color, M_Color knob_color, M_View* parent_view, Action action, void* data);

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
    @param data: the data that is being targeted by the slider
    @return A pointer to the slider.
*/
M_Slider* M_VRectSlider(MSize size, MPoint position, float minValue, float maxValue, float increment, M_Color track_color, M_Color background_color, M_Color knob_color, M_View* parent_view, Action action, void* data);

/*!
    Destroys the given slider.
    @param slider: the slider to be destroyed
*/
void M_DestroySlider(M_Slider* slider);

#ifdef __cplusplus
}
#endif

#endif // mac_sliders_h_