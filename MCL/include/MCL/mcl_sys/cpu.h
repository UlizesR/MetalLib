/*
    File:   cpu.h
    About:
        The cpu header file for MCL.
        Contains the cpu and its functions for the MCL application.
*/

#ifndef _mcl_cpu_h_
#define _mcl_cpu_h_

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

#endif

#ifdef __cplusplus
extern "C" {
#endif

double M_GetCPU();


#ifdef __cplusplus
}
#endif

#endif // _mcl_cpu_h_