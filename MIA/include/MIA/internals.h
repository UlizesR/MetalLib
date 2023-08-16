#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/*!
    A function pointer that is called when a GUI element is pressed.
    @param gui_element The GUI element that was pressed.
    @param data The data that is being targeted by the GUI element.
*/
typedef void (*Action)(void* gui_element, void* data);

#ifdef __cplusplus
}
#endif