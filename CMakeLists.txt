cmake_minimum_required(VERSION 3.10)
project(MACAPI)

# Set the C standard to C11
set(CMAKE_C_STANDARD 11)
set(CMAKE_OBJC_STANDARD 11) # or another version

# Add the include directories
include_directories(MACA/include)

# Combine C and Objective-C sources
set(SOURCES 
        MACA/src/mac_delegate.m
        MACA/src/mac_window.m
        MACA/src/mac_init.m
        MACA/src/mac_events.m
        MACA/src/Gui/mac_buttons.m
        MACA/src/Graphics/mac_view.m
        MACA/src/Graphics/mac_renderer.c
        MACA/src/Graphics/mac_shapes.m
)

# Create the library
add_library(MACA STATIC ${SOURCES})

# Link the necessary frameworks
target_link_libraries(MACA "-framework Cocoa" "-framework Metalkit" objc)

# Set the install location for the library
install(TARGETS MACA
        ARCHIVE DESTINATION /opt/homebrew/lib)

# Set the install location for the header files
install(DIRECTORY MACA/include/MACA/
        DESTINATION /opt/homebrew/include/MACA
        FILES_MATCHING PATTERN "*.h")
