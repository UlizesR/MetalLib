cmake_minimum_required(VERSION 3.10)
project(MACAPI)

# Set the C standard to C11
set(CMAKE_C_STANDARD 11)

# Add the include directories
include_directories(MACA/include)

# Create a variable with the sources
set(SOURCES
    MACA/src/mac_window.m
    MACA/src/mac_video.m
    MACA/src/mac_delegate.m
    MACA/src/maca.c
    MACA/src/mac_events.m
    MACA/src/mac_pixels.m
    MACA/src/mac_error.c
    MACA/src/Graphics/mac_view.m
    MACA/src/Graphics/mac_shapes.m
    MACA/src/Gui/mac_button.m
    MACA/src/Gui/mac_slider.m
)

# Create the library
add_library(MACA STATIC ${SOURCES})

# Link the necessary frameworks
target_link_libraries(MACA "-framework Cocoa" "-framework Metal")

# Set the install location for the library
install(TARGETS MACA
        ARCHIVE DESTINATION /opt/homebrew/lib)

# Set the install location for the header files
install(DIRECTORY MACA/include/MACA/
        DESTINATION /opt/homebrew/include/MAC
        FILES_MATCHING PATTERN "*.h")
