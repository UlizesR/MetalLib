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
)

# Create the library
add_library(MAC STATIC ${SOURCES})

# Link the necessary frameworks
target_link_libraries(MAC "-framework Cocoa" "-framework Metal")

# Create the executable
add_executable(main main.c)

# Link the library to the executable
target_link_libraries(main MAC)

# Make sure the compiler can find the MAC headers
target_include_directories(main PRIVATE MAC/include)

# Set the install location for the library
install(TARGETS MAC
        ARCHIVE DESTINATION /opt/homebrew/lib)

# Set the install location for the header files
install(DIRECTORY MAC/include/
        DESTINATION /opt/homebrew/include
        FILES_MATCHING PATTERN "*.h")
