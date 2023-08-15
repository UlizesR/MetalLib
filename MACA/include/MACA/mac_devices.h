#pragma once

#include "mac_defs.h"

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
    Struct to hold the data for a single Video/Graphics device
*/
typedef struct M_VDevice
{
    int idx;            // index of the device
    char name[50];      // name of the device
    void* device;       // pointer to the device for objective-c
    // other data
} M_VDevice;

typedef struct M_VDevicesList
{
    int count;          // number of devices
    M_VDevice* devices; // pointer to an array of devices
} M_VDevicesList;

/*!
    Returns the platform default video device
    @return the default video device
*/
M_VDevice* M_DefaultDevice();

/*!
    Returns the a specific device by index
    @param idx the index of the device
    @return the device
*/
M_VDevice* M_GetDevice(int idx);

/*!
    Returns a list of all available devices
    @return the list of devices
*/
M_VDevicesList* M_GetDevicesList();

#ifdef __cplusplus
}
#endif