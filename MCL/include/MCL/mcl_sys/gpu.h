/*
    File:   gpu.h
    About:
        The gpu header file for MCL.
        Contains the gpu and its functions for the MCL application.
*/

#ifndef _mcl_gpu_h_
#define _mcl_gpu_h_

typedef struct M_VDevice M_VDevice;

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
struct M_VDevice {
  const char *name; // The name of the device
  void *device;     // The device
  int id;           // The id of the device
#ifdef __OBJC__
  MVDevice *_device; // The device for Objective-C
#endif
};

// The list of devices
typedef struct M_VDeviceList {
  M_VDevice *devices; // The list of devices
  int count;          // The number of devices
} M_VDeviceList;

/*
    Returns the number of devices
*/
int M_GetVDeviceCount();

/*
    Returns the list of devices
*/
M_VDeviceList M_GetVDevices();

/*
    Returns the device with the given id
*/
M_VDevice *M_SetVDevice(int id);

/*
    Returns the default device of the system
*/
M_VDevice *M_GetVDevice();

/*
    Destroys the given device
*/
void M_DestroyVDevice(M_VDevice *device);

#ifdef __cplusplus
}
#endif

#endif // _mcl_gpu_h_