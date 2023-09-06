/*
    File:   sys_info.h
    About:
        The sys_info header file for MCL.
        Contains the sys_info and its functions for the MCL application.
*/

#ifndef _mcl_sys_info_h_
#define _mcl_sys_info_h_

#include "cpu.h"
#include "gpu.h"
#include "memory.h"

#include <stdint.h>


#ifdef __OBJC__

#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum MCL_SysInfoflags {
    MCL_SYS_INFO_ALL = 0,
    MCL_SYS_INFO_OS = 1,
    MCL_SYS_INFO_CPU = 2,
    MCL_SYS_INFO_GPU = 4,
    MCL_SYS_INFO_MEMORY = 8,
} MCL_SysInfoflags;

void MCL_SysInfo(uint32_t);

void MCL_OSInfo();


#ifdef __cplusplus
}
#endif

#endif // _mcl_sys_info_h_