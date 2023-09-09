#ifndef _mcl_sliders_h_
#define _mcl_sliders_h_

#include "../../MCL/defs.h"
#include "../../MCL/colors.h"

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

typedef enum {
  MCL_SLIDER_TICK_POSITION_ABOVE = 1,
  MCL_SLIDER_TICK_POSITION_BELOW = 2,
} MCL_Slider_Tick_Position;

typedef enum {
  MCL_SLIDER_HORIZONTAL = 1,
  MCL_SLIDER_VERTICAL = 2,
} MCL_Slider_Orientation;

typedef enum {
  MCL_SLIDER_STYLE_CIRCULAR = 1,
  MCL_SLIDER_STYLE_RECTANGULAR = 2,
} MCL_Slider_Style;

typedef struct MCL_Slider {
  int x, y, w, h;
  float value;
  float minValue;
  float maxValue;
  float increment;
  int style;
  MCL_ActionCallback action;
  void *data;
  void *_this;
} MCL_Slider;

/*!
    * @brief Creates a slider
    * @param frame The frame to add the slider to
    * @param slider The slider to create
    * @param x The x position of the slider
    * @param y The y position of the slider
    * @param w The width of the slider
    * @param h The height of the slider
    * @param minValue The minimum value of the slider
    * @param maxValue The maximum value of the slider
    * @param increment The increment of the slider
    * @param action The action callback of the slider
    * @param data The data to pass to the action callback
*/
void MCL_AddSlider(MCL_Frame *frame, MCL_Slider *slider, int x, int y, int w, int h, float minValue, float maxValue, float increment, int orientation, int style, MCL_ActionCallback action, void *data);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // _mcl_sliders_h_