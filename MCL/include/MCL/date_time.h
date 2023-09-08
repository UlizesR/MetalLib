#ifndef _mcl_timer_h_
#define _mcl_timer_h_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MCL_Date
{
    const char *weekday;
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
} MCL_Date;

// Define a struct to hold timer information
struct MCL_Timer {
  uint64_t startTime;
  double elapsed;
};

/*!
    * @brief Prints the current date to the console.
*/
void MCL_PrintDate();

/*!
    * @brief Gets the current date.
    * @param date The date to be filled.
*/
void MCL_GetDate(MCL_Date *date);

/*!
    * @brief Starts the timer.
    * @param id The id of the timer.
*/
void MCL_StartTimer(int id);

/*!
    * @brief Stops the timer.
    * @param id The id of the timer.
*/
void MCL_StopTimer(int id);

/*!
    * @brief Gets the elapsed time of a timer.
    * @param id The id of the timer.
*/
double MCL_GetElapsed(int id);

#ifdef __cplusplus
}
#endif

#endif // _mcl_timer_h_