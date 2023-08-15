#import "MACA/mac_devices.h"

#include <Metal/Metal.h>

static M_VDevice* createDevice(id<MTLDevice> metalDevice, int idx) {
    M_VDevice* device = (M_VDevice*)malloc(sizeof(M_VDevice));
    device->idx = idx;
    strncpy(device->name, [metalDevice.name UTF8String], sizeof(device->name) - 1);
    device->device = metalDevice;
    return device;
}

M_VDevice* M_DefaultDevice() {
    return createDevice(MTLCreateSystemDefaultDevice(), 0);
}

M_VDevice* M_GetDevice(int idx) {
    NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
    if (idx >= 0 && idx < devices.count) {
        return createDevice(devices[idx], idx);
    }
    return NULL;
}

M_VDevicesList* M_GetDevicesList() {
    NSArray<id<MTLDevice>> *devices = MTLCopyAllDevices();
    M_VDevicesList* list = (M_VDevicesList*)malloc(sizeof(M_VDevicesList));
    list->count = (int)devices.count;
    list->devices = (M_VDevice*)malloc(sizeof(M_VDevice) * devices.count);
    for (int i = 0; i < devices.count; i++) {
        list->devices[i] = *createDevice(devices[i], i);
    }
    return list;
}
