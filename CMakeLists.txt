cmake_minimum_required(VERSION 3.10)
project(MACAPI)

# Set the C standard to C11
set(CMAKE_C_STANDARD 11)

# Add the include directories
include_directories(MAC/include)

# Create a variable with the sources
set(SOURCES
    MAC/src/mac_window.m
    MAC/src/mac_view.m
    MAC/src/mac_delegate.m
    MAC/src/mac_video.m
    MAC/src/mac.m
    MAC/src/mac_events.m
    MAC/src/mac_pixels.m
    MAC/src/mac_error.c
    MAC/src/Gui/mac_button.m
    MAC/src/Gui/mac_slider.m
)

# Create the library
add_library(MAC STATIC ${SOURCES})

# Link the necessary frameworks
target_link_libraries(MAC "-framework Cocoa" "-framework Metal")

# Set the install location for the library
install(TARGETS MAC
        ARCHIVE DESTINATION /opt/homebrew/lib)

# Set the install location for the header files
install(DIRECTORY MAC/include/MAC/
        DESTINATION /opt/homebrew/include/MAC
        FILES_MATCHING PATTERN "*.h")
