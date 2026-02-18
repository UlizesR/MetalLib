cmake_minimum_required(VERSION 3.16)

project(GULI
    VERSION 1.0.0
    DESCRIPTION "Cross-platform C graphics library"
    LANGUAGES C OBJC
)

# ------------------------------------------------------------------------------
# Platform
# ------------------------------------------------------------------------------
option(GULI_FORCE_OPENGL "Force OpenGL backend (for testing on macOS)" OFF)

if(GULI_FORCE_OPENGL)
    set(GRAPHICS_API "opengl")
    add_compile_definitions(GULI_FORCE_OPENGL)
elseif(UNIX AND NOT APPLE)
    set(PLATFORM "linux")
    set(GRAPHICS_API "opengl")
elseif(WIN32)
    set(PLATFORM "windows")
    set(GRAPHICS_API "opengl")
elseif(APPLE)
    set(PLATFORM "macos")
    set(GRAPHICS_API "metal")
endif()

# ------------------------------------------------------------------------------
# Build configuration
# ------------------------------------------------------------------------------
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_OBJC_STANDARD 11)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(COMMON_FLAGS "-Wall -Wextra -Wpedantic -Wno-nullability-completeness")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMMON_FLAGS}")
set(CMAKE_OBJC_FLAGS "${CMAKE_OBJC_FLAGS} ${COMMON_FLAGS} -fobjc-arc -fno-objc-exceptions")

# Project include directory 
include_directories(${CMAKE_SOURCE_DIR}/include)

# ------------------------------------------------------------------------------
# Dependencies (GLFW + macOS frameworks)
# ------------------------------------------------------------------------------
# GLFW: build from submodule, disable extras for faster builds
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
add_subdirectory(external/glfw)

# cglm: math library for C
set(CGLM_USE_TEST OFF CACHE BOOL "" FORCE)
add_subdirectory(external/cglm)

# macOS frameworks and glfw flags
if(APPLE)
    target_compile_options(glfw PRIVATE -fno-objc-arc)
    find_library(COCOA_FRAMEWORK Cocoa REQUIRED)
    find_library(METAL_FRAMEWORK Metal REQUIRED)
    find_library(QUARTZCORE_FRAMEWORK QuartzCore REQUIRED)
    set(GULI_FRAMEWORKS ${COCOA_FRAMEWORK} ${METAL_FRAMEWORK} ${QUARTZCORE_FRAMEWORK})
endif()

# ------------------------------------------------------------------------------
# GULI library
# ------------------------------------------------------------------------------
file(GLOB GULI_CORE_SOURCES "src/Core/*.c")
if(GRAPHICS_API STREQUAL "metal")
    file(GLOB_RECURSE GULI_OBJC_SOURCES "src/*.m")
    add_library(GULI SHARED ${GULI_CORE_SOURCES} ${GULI_OBJC_SOURCES})
else()
    set(GULI_GL_SOURCES
        src/Graphics/OpenGL/guli_gl.c
        external/glad/src/glad.c
    )
    add_library(GULI SHARED ${GULI_CORE_SOURCES} ${GULI_GL_SOURCES})
    target_include_directories(GULI PRIVATE
        ${CMAKE_SOURCE_DIR}/external/glad/include
    )
    find_package(OpenGL REQUIRED)
    target_link_libraries(GULI PUBLIC glfw cglm OpenGL::GL)
endif()

target_compile_options(GULI PRIVATE -Wno-nullability-extension)

set_target_properties(GULI PROPERTIES
    OUTPUT_NAME "GULI"
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    MACOSX_RPATH ON
    BUILD_WITH_INSTALL_RPATH OFF
    INSTALL_RPATH "@executable_path/../lib;@loader_path"
)

target_include_directories(GULI PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/guli>
)

target_link_libraries(GULI PUBLIC glfw cglm)
if(APPLE)
    target_link_libraries(GULI PUBLIC ${GULI_FRAMEWORKS})
endif()

# ------------------------------------------------------------------------------
# Test executable (window backend only, no graphics)
# ------------------------------------------------------------------------------
add_executable(guli_test examples/main.c)
target_link_libraries(guli_test PRIVATE GULI)
target_include_directories(guli_test PRIVATE ${CMAKE_SOURCE_DIR}/include)