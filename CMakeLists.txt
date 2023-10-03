cmake_minimum_required(VERSION 3.10)
project(MCL2_API LANGUAGES C OBJC)

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
    MCL2/src/MCLCore/MCLApplication.m
    MCL2/src/MCLCore/MCLWindow.m
    MCL2/src/MCLCore/MCLEvents.m
    MCL2/src/MCLCore/MCLView.m

    MCL2/src/MCLGui/MCLButtons.m
    MCL2/src/MCLGui/MCLStackView.m
)

# Create the library
add_library(MCL2 STATIC ${SOURCES})

# Specify the include directories
target_include_directories(MCL2 PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL2/include>
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL2/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL2/include/MCL2> # Add this line
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/MCL2/include/MCL2/*> # Add this line
)


# Link the necessary frameworks
target_link_libraries(MCL2 "-framework Cocoa"  objc)

# Set the install location for the library
install(TARGETS MCL2
        EXPORT MCL2Targets
        ARCHIVE DESTINATION lib
        PUBLIC_HEADER DESTINATION include/MCL2
)

# Set the install location for the header files
install(DIRECTORY MCL2/include/MCL2/
        DESTINATION include/MCL2
        FILES_MATCHING PATTERN "*.h"
)

# Create an export file
install(EXPORT MCL2Targets
    FILE MCL2Targets.cmake
    NAMESPACE MCL2::
    DESTINATION lib/cmake/MCL2
)
