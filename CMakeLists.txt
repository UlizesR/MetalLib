cmake_minimum_required(VERSION 3.10)
project(MCL_API LANGUAGES C OBJC)

if(NOT APPLE)
    message(FATAL_ERROR "Cannot install library, Apple device required")
    return()
endif()

# Set the C standard to C11
set(CMAKE_C_STANDARD 11)
set(CMAKE_OBJC_STANDARD 11) # or another version
set(CMAKE_CXX_STANDARD 11) # or another version

# Combine C and Objective-C sources
set(SOURCES 
    MCL/src/delegate.m
    MCL/src/window.m
    MCL/src/events.m
    MCL/src/frame.m
    MCL/src/date_time.c
    MCL/src/mcl_sys/sys_info.m
    MCL/src/mcl_sys/cpu.m
    MCL/src/mcl_sys/memory.m
    MCL/src/mcl_sys/gpu.m
    MCL/src/gui/text.m
    MCL/src/gui/textbox.m
    MCL/src/gui/buttons.m
)

# Create the library
add_library(MCL STATIC ${SOURCES})

# Specify the include directories
target_include_directories(MCL PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL/include>
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL/include/MCL> # Add this line
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL/include/MCL/*> # Add this line
)


# Link the necessary frameworks
target_link_libraries(MCL "-framework Cocoa" "-framework Metal" "-framework Metalkit" objc)

# Set the install location for the library
install(TARGETS MCL
        EXPORT MCLTargets
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include/MCL
)

# Set the install location for the header files
install(DIRECTORY MCL/include/MCL/
        DESTINATION include/MCL
        FILES_MATCHING PATTERN "*.h"
)

# Create an export file
install(EXPORT MCLTargets
    FILE MCLTargets.cmake
    NAMESPACE MCL::
    DESTINATION lib/cmake/MCL
)
