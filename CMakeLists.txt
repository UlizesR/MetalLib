# ==============================================================================
# MetalLib (MKL) - CMake Build Configuration
# ==============================================================================
# A modern, high-performance graphics library for macOS using the Metal API
# 
# Requirements:
#   - macOS 10.15+ (Catalina or later)
#   - CMake 3.15+
#   - Xcode Command Line Tools with Metal support
#
# Build:
#   mkdir build && cd build
#   cmake ..
#   make -j8
#
# ==============================================================================

cmake_minimum_required(VERSION 3.15)

project(MetalLib 
    VERSION 1.0.0
    DESCRIPTION "Modern high-performance graphics library for macOS using Metal"
    LANGUAGES C OBJC
)

# ==============================================================================
# Platform Check
# ==============================================================================

if(NOT APPLE)
    message(FATAL_ERROR "MetalLib requires macOS (Metal is Apple-only)")
endif()

# ==============================================================================
# Build Configuration
# ==============================================================================

# Standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_OBJC_STANDARD 11)

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Default to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type (Debug/Release)" FORCE)
endif()

message(STATUS "==============================================================================")
message(STATUS "MetalLib Configuration")
message(STATUS "==============================================================================")
message(STATUS "Version:      ${PROJECT_VERSION}")
message(STATUS "Build type:   ${CMAKE_BUILD_TYPE}")
message(STATUS "System:       ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION}")
message(STATUS "C Compiler:   ${CMAKE_C_COMPILER}")
message(STATUS "Obj-C:        ${CMAKE_OBJC_COMPILER}")

# ==============================================================================
# Compiler Flags
# ==============================================================================

# Common warnings and settings
set(COMMON_FLAGS "-Wall -Wextra -Wpedantic -Wno-nullability-completeness")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMMON_FLAGS}")
set(CMAKE_OBJC_FLAGS "${CMAKE_OBJC_FLAGS} ${COMMON_FLAGS} -fobjc-arc -fno-objc-exceptions")

# Configuration-specific flags
if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_C_FLAGS_DEBUG "-g -O0 -DDEBUG")
    set(CMAKE_OBJC_FLAGS_DEBUG "-g -O0 -DDEBUG")
else()
    set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")
    set(CMAKE_OBJC_FLAGS_RELEASE "-O2 -DNDEBUG")
endif()

# ==============================================================================
# Required Frameworks
# ==============================================================================

find_library(COCOA_FRAMEWORK Cocoa REQUIRED)
find_library(METAL_FRAMEWORK Metal REQUIRED)
find_library(METALKIT_FRAMEWORK MetalKit REQUIRED)
find_library(QUARTZCORE_FRAMEWORK QuartzCore REQUIRED)
find_library(MODELIO_FRAMEWORK ModelIO REQUIRED)
find_library(IOKIT_FRAMEWORK IOKit REQUIRED)

set(MKL_FRAMEWORKS
    ${COCOA_FRAMEWORK}
    ${METAL_FRAMEWORK}
    ${METALKIT_FRAMEWORK}
    ${QUARTZCORE_FRAMEWORK}
    ${MODELIO_FRAMEWORK}
    ${IOKIT_FRAMEWORK}
)

# ==============================================================================
# MKL Library
# ==============================================================================

# Auto-discover source files
file(GLOB_RECURSE MKL_C_SOURCES "MKL/src/*.c")
file(GLOB_RECURSE MKL_OBJC_SOURCES "MKL/src/*.m")
set(MKL_SOURCES ${MKL_C_SOURCES} ${MKL_OBJC_SOURCES})

list(LENGTH MKL_C_SOURCES C_COUNT)
list(LENGTH MKL_OBJC_SOURCES OBJC_COUNT)
message(STATUS "Library sources: ${C_COUNT} C files, ${OBJC_COUNT} Objective-C files")

# Create shared library
add_library(mkl SHARED ${MKL_SOURCES})

# Library properties
set_target_properties(mkl PROPERTIES
    OUTPUT_NAME "mkl"
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    MACOSX_RPATH ON
    BUILD_WITH_INSTALL_RPATH OFF
    INSTALL_RPATH "@executable_path/../lib;@loader_path"
)

# Include directories
target_include_directories(mkl
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/MKL/src>
        $<INSTALL_INTERFACE:include>
)

# Link frameworks
target_link_libraries(mkl PUBLIC ${MKL_FRAMEWORKS})

message(STATUS "MKL library: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libmkl.dylib")

# ==============================================================================
# Resources (Shaders and Assets)
# ==============================================================================

# Copy Metal shaders to build directory
file(GLOB_RECURSE METAL_SHADERS "MKL/src/Graphics/Shaders/*.metal")
foreach(SHADER ${METAL_SHADERS})
    get_filename_component(SHADER_NAME ${SHADER} NAME)
    configure_file(
        ${SHADER} 
        ${CMAKE_BINARY_DIR}/bin/shaders/${SHADER_NAME} 
        COPYONLY
    )
endforeach()

# Create symlink to MKL source for runtime shader access
add_custom_target(mkl_resources ALL
    COMMAND ${CMAKE_COMMAND} -E create_symlink 
        ${CMAKE_SOURCE_DIR}/MKL 
        ${CMAKE_BINARY_DIR}/bin/MKL
    COMMENT "Creating MKL symlink for shader access"
)
add_dependencies(mkl_resources mkl)

# Copy example assets if they exist
if(EXISTS "${CMAKE_SOURCE_DIR}/examples/assets")
    file(GLOB EXAMPLE_ASSETS "examples/assets/*")
    foreach(ASSET ${EXAMPLE_ASSETS})
        get_filename_component(ASSET_NAME ${ASSET} NAME)
        configure_file(
            ${ASSET} 
            ${CMAKE_BINARY_DIR}/bin/assets/${ASSET_NAME} 
            COPYONLY
        )
    endforeach()
endif()

# Copy example-specific shaders
file(GLOB_RECURSE EXAMPLE_SHADERS "examples/*/*.metal")
foreach(SHADER ${EXAMPLE_SHADERS})
    get_filename_component(SHADER_NAME ${SHADER} NAME)
    configure_file(
        ${SHADER} 
        ${CMAKE_BINARY_DIR}/bin/${SHADER_NAME} 
        COPYONLY
    )
endforeach()

message(STATUS "Resources: Shaders and assets copied to ${CMAKE_BINARY_DIR}/bin/")

# ==============================================================================
# Auto-Discover Examples
# ==============================================================================

message(STATUS "==============================================================================")
message(STATUS "Discovering Examples")
message(STATUS "==============================================================================")

# Find all .c files in examples/ subdirectories
file(GLOB_RECURSE EXAMPLE_SOURCES "examples/*/*.c")

# Process each example
foreach(EXAMPLE_SOURCE ${EXAMPLE_SOURCES})
    # Get relative path and extract category/name
    file(RELATIVE_PATH REL_PATH ${CMAKE_SOURCE_DIR}/examples ${EXAMPLE_SOURCE})
    get_filename_component(EXAMPLE_DIR ${REL_PATH} DIRECTORY)
    get_filename_component(EXAMPLE_NAME_ONLY ${EXAMPLE_SOURCE} NAME_WE)
    
    # Create sanitized target name (replace / with _)
    string(REPLACE "/" "_" TARGET_NAME ${EXAMPLE_DIR})
    set(TARGET_NAME "${TARGET_NAME}_${EXAMPLE_NAME_ONLY}")
    
    # Create executable
    add_executable(${TARGET_NAME} ${EXAMPLE_SOURCE})
    
    # Set output name (without category prefix for cleaner bin/)
    set_target_properties(${TARGET_NAME} PROPERTIES
        OUTPUT_NAME "${TARGET_NAME}"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    )
    
    # Include MKL headers
    target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/MKL/src)
    
    # Link MKL library
    target_link_libraries(${TARGET_NAME} PRIVATE mkl)
    
    # Set RPATH for finding libmkl.dylib
    set_target_properties(${TARGET_NAME} PROPERTIES
        BUILD_WITH_INSTALL_RPATH OFF
        INSTALL_RPATH "@executable_path/../lib;@loader_path/../lib"
        BUILD_RPATH "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
    )
    
    # Add dependency
    add_dependencies(${TARGET_NAME} mkl)
    
    message(STATUS "  ${EXAMPLE_DIR}/${EXAMPLE_NAME_ONLY}.c -> ${TARGET_NAME}")
endforeach()

list(LENGTH EXAMPLE_SOURCES EXAMPLE_COUNT)
message(STATUS "Total examples: ${EXAMPLE_COUNT}")


# ==============================================================================
# Installation Rules
# ==============================================================================

# Install library
install(TARGETS mkl
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install headers (preserve directory structure)
install(DIRECTORY MKL/src/
    DESTINATION include/MKL
    FILES_MATCHING PATTERN "*.h"
)

# Install shaders
install(DIRECTORY MKL/src/Graphics/Shaders/
    DESTINATION share/mkl/shaders
    FILES_MATCHING PATTERN "*.metal"
)

# Install pkg-config file
configure_file(
    ${CMAKE_SOURCE_DIR}/mkl.pc.in
    ${CMAKE_BINARY_DIR}/mkl.pc
    @ONLY
)
install(FILES ${CMAKE_BINARY_DIR}/mkl.pc
    DESTINATION lib/pkgconfig
)

message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

# ==============================================================================
# Custom Targets
# ==============================================================================

# Clean all build artifacts
add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/bin
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/lib
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/tests
    COMMENT "Removing all build artifacts"
)

# List all built targets
add_custom_target(list-targets
    COMMAND ${CMAKE_COMMAND} -E echo "Built targets:"
    COMMAND ls -lh ${CMAKE_BINARY_DIR}/bin/ 2>/dev/null || true
    COMMENT "Listing built executables"
)

# ==============================================================================
# Summary
# ==============================================================================

message(STATUS "==============================================================================")
message(STATUS "Build Summary")
message(STATUS "==============================================================================")
message(STATUS "Library:      ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/libmkl.${PROJECT_VERSION}.dylib")
message(STATUS "Examples:     ${CMAKE_BINARY_DIR}/bin/")
message(STATUS "Tests:        ${CMAKE_BINARY_DIR}/tests/")
message(STATUS "")
message(STATUS "Build Commands:")
message(STATUS "  make              - Build library, examples, and tools")
message(STATUS "  make mkl          - Build library only")
message(STATUS "  make test         - Run all tests")
message(STATUS "  make install      - Install library system-wide")
message(STATUS "  make clean-all    - Remove all build artifacts")
message(STATUS "  make list-targets - List all built executables")
message(STATUS "")
message(STATUS "Run Examples:")
message(STATUS "  cd ${CMAKE_SOURCE_DIR} && ./build/bin/<example_name>")
message(STATUS "==============================================================================")
