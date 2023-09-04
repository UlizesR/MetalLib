#import "MCL/mcl_sys/sys_info.h"
#include "MCL/mcl_sys/gpu.h"
#include <stdint.h>

#import <Cocoa/Cocoa.h>

void MCL_SysInfo(uint32_t flags)
{
  if (flags & MCL_SYS_INFO_OS)
  {
    MCL_OSInfo();
  }
  if (flags & MCL_SYS_INFO_CPU)
  {
    MCL_CPUInfo();
  }
  if (flags & MCL_SYS_INFO_GPU)
  {
    MCL_VDeviceInfo();
  } else {
    MCL_OSInfo();
    MCL_CPUInfo();
    MCL_VDeviceInfo();
  }
}

void MCL_OSInfo()
{
  NSProcessInfo *processInfo = [NSProcessInfo processInfo];
  NSOperatingSystemVersion os_version = [processInfo operatingSystemVersion];
  NSString *os_name = [processInfo operatingSystemVersionString];
  printf("OS Name: %s\n", [os_name UTF8String]);
  printf("OS Version: %ld.%ld.%ld\n", (long)os_version.majorVersion, (long)os_version.minorVersion, (long)os_version.patchVersion);
}