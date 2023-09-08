#include "MCL/date_time.h"
#include <mach/mach_time.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

void MCL_PrintDate() 
{
  // Get the current time
  time_t now = time(NULL);
  struct tm *tm = localtime(&now);

  // Convert the time to a string
  char timeStr[100];
  strftime(timeStr, sizeof(timeStr), "%A %B %d %Y %H:%M:%S", tm);

  // Print the date and time
  printf("The current date and time is: %s\n", timeStr);
}

void MCL_GetDate(MCL_Date *date) 
{
  // Get the current time
  time_t now = time(NULL);
  struct tm *tm = localtime(&now);

  // Fill the MCL_Date struct with the current date and time
  char weekday[10];
  strftime(weekday, sizeof(weekday), "%A", tm);
  date->weekday = strdup(weekday);
  date->year = tm->tm_year + 1900;
  date->month = tm->tm_mon + 1;
  date->day = tm->tm_mday;
  date->hour = tm->tm_hour;
  date->minute = tm->tm_min;
  date->second = tm->tm_sec;
}

// Define a global map to hold timer information
struct MCL_Timer timers[50];

void MCL_StartTimer(int id) {
  // Get the current time and store it in the global map
  timers[id].startTime = mach_absolute_time();
}

void MCL_StopTimer(int id) {
  // Get the current time and calculate the elapsed time
  uint64_t endTime = mach_absolute_time();
  uint64_t elapsed = endTime - timers[id].startTime;

  // Convert the elapsed time to seconds
  mach_timebase_info_data_t timebase;
  mach_timebase_info(&timebase);
  timers[id].elapsed =
      (double)elapsed * (double)timebase.numer / (double)timebase.denom / 1e9;
}

double MCL_GetElapsed(int id) {
  // Return the elapsed time for the specified timer
  return timers[id].elapsed;
}