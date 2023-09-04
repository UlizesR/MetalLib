/*
    File:   gpu.h
    About:
        The gpu header file for MCL.
        Contains the gpu and its functions for the MCL application.
*/

#ifndef _mcl_gpu_h_
#define _mcl_gpu_h_

typedef struct MCL_VDevice MCL_VDevice;

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface MVDevice : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) id<MTLDevice> device;
@property(nonatomic, assign) int id;

- (id)initDefaultDevice;

- (id)initWithID:(int)id;

@end

#endif

#ifdef __cplusplus
extern "C" {
#endif


// The Video Device Info
struct MCL_VDevice {
  const char *name; // The name of the device
  void *device;     // The device
  int id;           // The id of the device
#ifdef __OBJC__
  MVDevice *_device; // The device for Objective-C
#endif
};

// The list of devices
typedef struct MCL_VDeviceList {
  MCL_VDevice *devices; // The list of devices
  int count;          // The number of devices
} MCL_VDeviceList;

/*
    Returns the number of devices
*/
int MCL_GetVDeviceCount();

/*
    Returns the list of devices
*/
MCL_VDeviceList MCL_GetVDevices();

/*
    Returns the device with the given id
*/
MCL_VDevice *MCL_SetVDevice(int id);

/*
    prints the device info
*/
void MCL_VDeviceInfo();

/*
    Returns the default device of the system
*/
MCL_VDevice *MCL_GetVDevice();

/*
    Destroys the given device
*/
void MCL_DestroyVDevice(MCL_VDevice *device);

#ifdef __cplusplus
}
#endif

#endif // _mcl_gpu_h_