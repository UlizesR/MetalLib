/*
    File:   cpu.h
    About:
        The cpu header file for MCL.
        Contains the cpu and its functions for the MCL application.
*/

#ifndef _mcl_cpu_h_
#define _mcl_cpu_h_

#include <mach/mach_host.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

#endif

#ifdef __cplusplus
extern "C" {
#endif

void MCL_CPUInfo();

/*
    CPU Info related to the app itself
*/
void MCL_GetAppCPUUsage(double *usage);

/*
    CPU Info related to the system
*/


#ifdef __cplusplus
}
#endif

#endif // _mcl_cpu_h_