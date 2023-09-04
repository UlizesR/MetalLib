#import "MCL/mcl_sys/cpu.h"

#import <Cocoa/Cocoa.h>


void MCL_CPUInfo() {
    NSProcessInfo *pInfo = [NSProcessInfo processInfo];
    printf("CPU Name: %s\n", [[pInfo processName] UTF8String]);
    printf("CPU Host Name: %s\n", [[pInfo hostName] UTF8String]);
    printf("CPU Process ID: %d\n", [pInfo processIdentifier]);
    printf("CPU Globally Unique Identifier: %s\n", [[pInfo globallyUniqueString] UTF8String]);
    printf("CPU Physical Memory: %llu GB\n", [pInfo physicalMemory] / 1024 / 1024 / 1024);
    printf("CPU Core Count: %lu\n", (unsigned long)[pInfo processorCount]);
    printf("CPU active Core Count: %lu\n", (unsigned long)[pInfo activeProcessorCount]);
    printf("CPU low power mode enabled: %s\n", [pInfo isLowPowerModeEnabled] ? "true" : "false");
    if ([pInfo thermalState] == NSProcessInfoThermalStateNominal) {
        printf("CPU Thermal State: Nominal\n");
    } else if ([pInfo thermalState] == NSProcessInfoThermalStateFair) {
        printf("CPU Thermal State: Fair\n");
    } else if ([pInfo thermalState] == NSProcessInfoThermalStateSerious) {
        printf("CPU Thermal State: Serious\n");
    } else if ([pInfo thermalState] == NSProcessInfoThermalStateCritical) {
        printf("CPU Thermal State: Critical\n");
    } else {
        printf("CPU Thermal State: Unknown\n");
    }
}

void MCL_GetAppCPUUsage(double *usage) {
    // Get the process info
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kerr != KERN_SUCCESS) {
        *usage = -1.0;
        return;
    } 
    // Calculate the CPU usage percentage
    double total_time = (double)info.user_time.seconds + (double)info.system_time.seconds;
    double total_cpu_usage = total_time / (double)info.resident_size;
    *usage = total_cpu_usage * 100.0;
}