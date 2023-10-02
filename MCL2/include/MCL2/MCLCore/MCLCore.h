/*
    File:   MCLCore.h
    About:
        The core header file for MCL.
        Contains the core functions for the MCL framework.
*/

#ifndef _mcl_core_h_
#define _mcl_core_h_

#ifndef __APPLE__
#error "MCL is only supported on Apple macOS platform."
#endif

#ifdef __is_target_os
#if !__is_target_os(macOS)
#error "MCL is only currently supported on macOS."
#endif
#endif

// Get the version of the MCL framework
#define MCL_VERSION_MAJOR 0
#define MCL_VERSION_MINOR 1
#define MCL_VERSION_PATCH 0

// Set the MCL framework version
#define MCL_VERSION #MCL_VERSION_MAJOR "." #MCL_VERSION_MINOR "." #MCL_VERSION_PATCH

typedef struct MCL_App MCL_App;             // The app
typedef struct MCL_Window MCL_Window;       // The window
typedef struct MCL_View MCL_View;           // The view

typedef void (*MCL_ActionCallback)(void *data);

#endif // _mcl_core_h_