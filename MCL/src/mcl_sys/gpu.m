#import "MCL/mcl_sys/gpu.h"
#include <objc/objc.h>
#include <stdio.h>

// Get the OBJ-C Frameworks
#include <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>

@implementation MVDevice

- (id)initDefaultDevice 
{
    // Initialize the device and check if the initialization was successful
    self = [super init];
    if (!self) 
    {
        fprintf(stderr, "Error: Failed to initialize MVDevice\n");
        return nil;
    }
    // Get the default device
    self.device = MTLCreateSystemDefaultDevice();
    // Check if the device was found
    if (!self.device)
    {
        fprintf(stderr, "Error: Failed to get default device\n");
        return nil;
    }
    // Get the device's name
    self.name = self.device.name;
    self.id = 0;
    return self;
}

- (id)initWithID:(int)id
{
    // Initialize the device and check if the initialization was successful
    self = [super init];
    if (!self) 
    {
        fprintf(stderr, "Error: Failed to initialize MVDevice\n");
        return nil;
    }
    // Set the device id
    self.id = id;
    // Get the device with the specified id
    for (int i = 0; i < MTLCopyAllDevices().count; i++)
    {
        if (i == id)
        {
            self.device = MTLCopyAllDevices()[i];
            break;
        }
    }
    // Check if the device was found
    if (!self.device)
    {
        fprintf(stderr, "Error: Failed to get device with id %d\n", id);
        return nil;
    }
    // Get the device's name
    self.name = self.device.name;
    return self;
}

@end

int MCL_GetVDeviceCount()
{
    NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
    return (int)devices.count;
}

MCL_VDeviceList MCL_GetVDevices() {
    // Get the devices
    NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
    MCL_VDeviceList deviceList;
    // Allocate memory for the device list
    deviceList.devices = (MCL_VDevice *)malloc(sizeof(MCL_VDevice) * devices.count);
    // Check if the allocation was successful
    if (!deviceList.devices) {
        fprintf(stderr, "Error: Failed to allocate memory for MCL_VDeviceList\n");
        return deviceList;
    }
    // Set the device list's devices
    for (int i = 0; i < devices.count; i++) {
        deviceList.devices[i].name = devices[i].name.UTF8String;
        deviceList.devices[i].device = (__bridge void *)devices[i];
        deviceList.devices[i].id = i;
        deviceList.devices[i]._device = devices[i];
    }
    // Set the device list's count
    deviceList.count = (int)devices.count;
    return deviceList;
}

MCL_VDevice *MCL_SetVDevice(int id) {
    // Allocate memory for the device and check if the allocation was successful
    MCL_VDevice *device = (MCL_VDevice *)malloc(sizeof(MCL_VDevice));
    if (!device) {
        fprintf(stderr, "Error: Failed to allocate memory for MCL_VDevice\n");
        return NULL;
    }
    // Initialize the device
    MVDevice *vdevice = [[MVDevice alloc] initWithID:id];
    // Check if the initialization was successful
    if (!vdevice) {
        fprintf(stderr, "Error: Failed to initialize MVDevice\n");
        return NULL;
    }
    // Set the device's properties
    device->device = (__bridge void *)vdevice;
    device->_device = vdevice;
    device->id = id;
    device->name = [vdevice.name UTF8String];
    return device;
}

void MCL_VDeviceInfo()
{
    NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
    for (id<MTLDevice> device in devices)
    {
        printf("(GPU) Video Device Name: %s\n", device.name.UTF8String);
        printf("(GPU) Video Device Low Power: %s\n", device.lowPower ? "true" : "false");
        printf("(GPU) Video Device Headless: %s\n", device.headless ? "true" : "false");
        printf("(GPU) Video Device Registry ID: %llu\n", device.registryID);
        // printf("(GPU) Video Device Max Threads Per Threadgroup: %llu\n", device.maxThreadsPerThreadgroup);
        printf("(GPU) Video Device Max Threadgroup Memory Length: %lu\n", (unsigned long)device.maxThreadgroupMemoryLength);
        printf("(GPU) Video Device Max Argument Buffer Sampler Count: %lu\n", (unsigned long)device.maxArgumentBufferSamplerCount);
        printf("(GPU) Video Device Metal Max Buffer Length: %lu\n", (unsigned long)device.maxBufferLength);
        printf("(GPU) Video Device Metal Max Threadgroup Memory Length: %lu\n", (unsigned long)device.maxThreadgroupMemoryLength);
        printf("(GPU) Video Device is removable: %s\n", device.removable ? "true" : "false");

        if ([device location] == MTLDeviceLocationBuiltIn) {
          printf("(GPU) Video Device location: Built In\n");
        } else if ([device location] == MTLDeviceLocationExternal) {
          printf("(GPU) Video Device location: External\n");
        } else {
          printf("(GPU) Video Device location: Unknown\n");
        }
        printf("(GPU) Video Device location ID: %li\n", device.locationNumber);
    }
}

MCL_VDevice *MCL_GetVDevice() {
  // Allocate memory for the device and check if the allocation was successful
  MCL_VDevice *device = (MCL_VDevice *)malloc(sizeof(MCL_VDevice));
  if (!device) {
    fprintf(stderr, "Error: Failed to allocate memory for MCL_VDevice\n");
    return NULL;
  }
  // Initialize the device
  MVDevice *vdevice = [[MVDevice alloc] initDefaultDevice];
  // Check if the initialization was successful
  if (!vdevice) {
    fprintf(stderr, "Error: Failed to initialize MVDevice\n");
    return NULL;
  }
  // Set the device's properties
  device->device = (__bridge void *)vdevice;
  device->_device = vdevice;
  device->id = vdevice.id;
  device->name = [vdevice.name UTF8String];
  return device;
}

void MCL_DestroyVDevice(MCL_VDevice *device)
{
    free(device);
}