cmake_minimum_required(VERSION 3.10)
project(MIA_API)

# Set the C standard to C11
set(CMAKE_C_STANDARD 11)
set(CMAKE_OBJC_STANDARD 11) # or another version

# Add the include directories
include_directories(MIA/include)

# Combine C and Objective-C sources
set(SOURCES 
    MIA/src/delegate.m
    MIA/src/window.m
    MIA/src/init.m
    MIA/src/devices.m
    MIA/src/view.m
    MIA/src/events.m
    MIA/src/Gui/buttons.m
    MIA/src/Gui/sliders.m
)

# Create the library
add_library(MIA STATIC ${SOURCES})

# Link the necessary frameworks
target_link_libraries(MIA "-framework Cocoa" objc)

# Set the install location for the library
install(TARGETS MIA
        ARCHIVE DESTINATION /opt/homebrew/lib)

# Set the install location for the header files
install(DIRECTORY MIA/include/MIA/
        DESTINATION /opt/homebrew/include/MIA
        FILES_MATCHING PATTERN "*.h")
