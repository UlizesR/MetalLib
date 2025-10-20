# MKL Examples - Complete Guide

All examples are organized by complexity and feature category. Each example is self-contained and demonstrates specific features.

## 📁 Example Structure

```
examples/
├── 01_basics/          # Getting started
├── 02_graphics/        # Shapes and shaders
├── 03_lighting/        # Lighting system
├── 04_advanced/        # Advanced features
├── 05_performance/     # Optimization techniques
├── 06_models/          # Model loading
└── assets/             # Shared resources (models, textures)
```

---

## 🚀 Quick Start

### Build All Examples:
```bash
make all
```

### Build by Category:
```bash
make basics      # Build all basic examples
make graphics    # Build all graphics examples
make lighting    # Build lighting demos
make advanced    # Build advanced examples
make performance # Build performance demos
make models      # Build model loading examples
```

### Build Individual Example:
```bash
make hello          # Simplest example
make lights         # Lighting demo
make camera-modes   # Camera modes
make instancing     # 3375 cubes!
```

### Run Examples:
```bash
./build/bin/01_hello_cube
./build/bin/03_lighting_demo
./build/bin/04_camera_modes
```

---

## 📚 Examples by Category

### 01 - Basics (Start Here!)

#### `01_hello_cube` - Your First MKL Program
**File:** `01_basics/hello_cube.c`  
**Build:** `make hello`  
**Run:** `./build/bin/01_hello_cube`

**What it shows:**
- Window and renderer creation
- Basic rendering loop
- Simple rotating cube
- Camera setup

**Perfect for:** Complete beginners

---

#### `01_camera_controls` - Learn Camera Movement
**File:** `01_basics/camera_controls.c`  
**Build:** `make camera-ctrl`  
**Run:** `./build/bin/01_camera_controls`

**What it shows:**
- WASD movement
- Mouse look controls  
- Camera navigation in 3D space
- Ground grid for reference
- Axis markers (RGB cubes)

**Features:**
- `MKLCameraMoveForward()`, `MKLCameraMoveRight()`, `MKLCameraMoveUp()`
- `MKLCameraYaw()`, `MKLCameraPitch()`
- Mouse delta tracking

**Perfect for:** Learning 3D navigation

---

### 02 - Graphics

#### `02_shapes_demo` - All Primitive Shapes
**File:** `02_graphics/shapes_demo.c`  
**Build:** `make shapes`  
**Run:** `./build/bin/02_shapes_demo`

**What it shows:**
- All 3D primitives (cube, sphere, cylinder, cone, torus, plane)
- All 2D shapes (circle, rectangle, triangle, polygon, line)
- **NEW:** Enhanced rendering with lighting
- Camera movement
- Shape transformations

**Features:**
- `MKLDrawCube()`, `MKLDrawSphere()`, `MKLDrawCylinder()`, etc.
- `MKLDrawCircle()`, `MKLDrawRectangle()`, `MKLDrawTriangle()`, etc.
- `MKLEnableEnhancedRendering()` - Toggle lighting
- Press 'L' to see lighting effects!

**Perfect for:** Understanding all available shapes

---

#### `02_custom_shader` - ShaderToy-Style Custom Shaders
**File:** `02_graphics/custom_shader.c`  
**Build:** `make shader`  
**Run:** `./build/bin/02_custom_shader`

**What it shows:**
- Loading custom Metal shaders at runtime
- Passing uniforms to shaders (time, resolution)
- Fullscreen shader rendering
- ShaderToy-compatible shaders

**Features:**
- `MKLLoadShader()`
- `MKLSetShaderFloat()`, `MKLSetShaderVec2()`
- `MKLBeginFullscreenShader()`, `MKLEndFullscreenShader()`

**Perfect for:** Shader artists, visual effects

---

### 03 - Lighting

#### `03_lighting_demo` - Real-Time Lighting System ✨
**File:** `03_lighting/lighting_demo.c`  
**Build:** `make lights` or `make lighting`  
**Run:** `./build/bin/03_lighting_demo`

**What it shows:**
- **Visible lighting with specular highlights!**
- Multiple light types (ambient, directional, point)
- Dynamic lighting (moving point light)
- Blinn-Phong shading model
- Toggle lighting on/off

**Features:**
- `MKLCreateAmbientLight()`, `MKLCreateDirectionalLight()`, `MKLCreatePointLight()`
- `MKLAddLight()`, `MKLUpdateLight()`
- `MKLEnableEnhancedRendering()`
- Enhanced vertex format with normals

**Visual Effects:**
- ✨ **Shiny specular highlights** on cube edges
- 🌞 Directional shading (bright/dark sides)
- 💡 Blue tint from moving point light
- 🌑 Ambient base lighting

**Perfect for:** Understanding lighting systems

**TIP:** Press 'L' to toggle lighting and see the dramatic difference!

---

### 04 - Advanced

#### `04_camera_modes` - All Camera Modes
**File:** `04_advanced/camera_modes.c`  
**Build:** `make camera-modes` or `make advanced`  
**Run:** `./build/bin/04_camera_modes`

**What it shows:**
- **4 different camera modes** (Free, First Person, Orbital, Third Person)
- Interactive mode switching
- Mode-specific behaviors
- Auto-rotating orbital mode

**Features:**
- `MKLSetCameraMode()` - Switch between modes
- `MKL_CAMERA_FREE`, `MKL_CAMERA_FIRST_PERSON`, `MKL_CAMERA_ORBITAL`, `MKL_CAMERA_THIRD_PERSON`
- Automatic camera behavior per mode

**Controls:**
- **1** - FREE mode (fly anywhere)
- **2** - FIRST PERSON mode (FPS-style, ground-locked)
- **3** - ORBITAL mode (auto-rotate around center!)
- **4** - THIRD PERSON mode (follow target)

**Perfect for:** Learning different camera control schemes

---

### 05 - Performance

#### `05_instanced_rendering` - GPU Instancing
**File:** `05_performance/instanced_rendering.c`  
**Build:** `make instancing` or `make performance`  
**Run:** `./build/bin/05_instanced_rendering`

**What it shows:**
- **3,375 cubes rendered in a single draw call!**
- GPU instancing for massive performance
- Per-instance transforms
- Rainbow color effect
- Waving animation
- 60+ FPS with thousands of objects

**Features:**
- `MKLDrawCubesInstanced()` - Batch rendering
- Per-instance data (transform, color)
- Single draw call efficiency

**Performance:**
- 3,375 cubes @ 60+ FPS
- Minimal CPU overhead
- Stable memory usage

**Perfect for:** Learning GPU instancing optimization

---

### 06 - Models

#### `06_obj_viewer` - 3D Model Loader
**File:** `06_models/obj_viewer.c`  
**Build:** `make obj` or `make models`
**Run:** `./build/bin/06_obj_viewer`

**What it shows:**
- Loading .obj files with ModelIO
- Complex geometry rendering (97,836 vertices!)
- Automatic normal generation
- Camera navigation around models
- **NEW:** Lighting on loaded models

**Features:**
- `MKLMeshCreateWithFile()` - Load OBJ files
- `MKLDrawMesh()` - Render loaded models
- Automatic normal generation if missing
- UV coordinates preserved

**Controls:**
- WASD - Move camera
- Mouse drag - Look around
- Space/Q - Up/down
- L - Toggle lighting

**Perfect for:** Loading and viewing 3D models

---

## 🎮 Controls Reference

Most examples use these standard controls:

| Key/Input | Action |
|-----------|--------|
| **WASD** | Move camera (forward/left/backward/right) |
| **Space** | Move up |
| **Q** | Move down |
| **Mouse Drag** | Look around (rotate view) |
| **ESC** | Exit program |
| **L** | Toggle lighting (in lighting-enabled examples) |
| **1-4** | Switch camera modes (in camera_modes example) |

---

## 🔧 Build System

### New Organized Makefile

The Makefile is now organized by example categories:

```bash
# Build everything
make all

# Build by category
make basics
make graphics
make lighting
make advanced
make performance
make models

# Build individual examples (short names)
make hello
make camera-ctrl
make shapes
make shader
make lights
make camera-modes
make instancing
make obj

# Utility
make clean      # Remove all build artifacts
make help       # Show all available targets
```

**Output Location:** All binaries go to `./build/bin/`  
**Library Location:** `./build/lib/libmkl.dylib`

---

## 📊 Feature Matrix

| Example | Rendering | Lighting | Camera Modes | Custom Shaders | Instancing | Models |
|---------|-----------|----------|--------------|----------------|------------|--------|
| 01_hello_cube | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 01_camera_controls | ✅ | ❌ | ⚠️ FPS | ❌ | ❌ | ❌ |
| 02_shapes_demo | ✅ | ✅ | ⚠️ FPS | ❌ | ❌ | ❌ |
| 02_custom_shader | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| 03_lighting_demo | ✅ | ✅ | ⚠️ FPS | ❌ | ❌ | ❌ |
| 04_camera_modes | ✅ | ✅ | ✅ All | ❌ | ❌ | ❌ |
| 05_instanced_rendering | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| 06_obj_viewer | ✅ | ✅ | ⚠️ FPS | ❌ | ❌ | ✅ |

Legend: ✅ Full support | ⚠️ Partial | ❌ Not used

---

## 🎯 Learning Path

### Beginner Path:
1. `01_hello_cube` - Understand basic structure
2. `01_camera_controls` - Learn navigation
3. `02_shapes_demo` - See all primitives
4. `03_lighting_demo` - Understand lighting
5. `04_camera_modes` - Master camera control

### Graphics Artist Path:
1. `02_shapes_demo` - All shapes
2. `02_custom_shader` - Shader programming
3. `03_lighting_demo` - Lighting effects
4. `06_obj_viewer` - Model loading

### Game Developer Path:
1. `01_camera_controls` - Basic FPS controls
2. `04_camera_modes` - Camera systems
3. `05_instanced_rendering` - Performance optimization
4. `03_lighting_demo` - Realistic lighting

---

## 💡 Tips

### For Each Example:

**`01_hello_cube`**
- Simplest possible MKL program
- Good template for new projects
- ~80 lines of code

**`01_camera_controls`**
- Shows proper camera implementation
- Use as reference for your own projects
- Demonstrates new camera functions

**`02_shapes_demo`**
- **Press 'L'** to toggle lighting!
- See how lighting affects different shapes
- Great for testing primitives

**`02_custom_shader`**
- Edit `shadertoy.metal` to experiment
- Real-time shader reload possible
- ShaderToy shaders work with minor modifications

**`03_lighting_demo`**
- **MUST SEE** for lighting effects
- Press 'L' to see before/after
- Watch the moving blue point light
- Look for shiny highlights!

**`04_camera_modes`**
- Press 1-4 to switch modes instantly
- Watch orbital mode auto-rotate
- Compare how movement feels in each mode

**`05_instanced_rendering`**
- 3,375 cubes @ 60 FPS!
- Shows GPU instancing power
- Perfect for particle systems, crowds, forests

**`06_obj_viewer`**
- Load your own .obj files!
- Edit path in source to load different models
- Supports complex meshes (97K+ vertices)

---

## 🔍 What's New in Organized Examples

### All Examples Now Use:
✅ New camera system with proper modes  
✅ Enhanced rendering where appropriate  
✅ Consistent control schemes  
✅ Better organization and documentation  
✅ Modern C coding practices  

### Improved Features:
- **Lighting integration** in shapes_demo, lighting_demo, camera_modes, obj_viewer
- **Camera functions** instead of manual vector math
- **Better commenting** and structure
- **Consistent naming** (01_, 02_, etc.)

---

## 🎨 Visual Quick Reference

### What Each Example Looks Like:

**01_hello_cube:**
```
Simple blue cube rotating on screen
```

**01_camera_controls:**
```
Grid floor + colored axis markers
Move around to explore
```

**02_shapes_demo:**
```
Multiple shapes (cube, sphere, cylinder, etc.)
With/without lighting toggle
```

**02_custom_shader:**
```
Fullscreen shader effect (fractal/raymarching)
Animated over time
```

**03_lighting_demo:**
```
15 cubes with:
- Shiny highlights ✨
- Moving blue point light 💡
- Directional shading 🌞
```

**04_camera_modes:**
```
Central red cube + ground grid
Auto-rotate in orbital mode
Switch between 4 camera styles
```

**05_instanced_rendering:**
```
15x15x15 grid = 3,375 cubes!
Waving animation
Rainbow colors
Smooth 60 FPS
```

**06_obj_viewer:**
```
Complex 3D model
97,836 vertices
Smooth shading
Rotate camera to explore
```

---

## 📖 Example Template

Use this as a starting point for your own MKL projects:

```c
#include "MKL.h"

int main(void) {
    // Initialize
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(1200, 800, "My App");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    // Setup camera
    renderer->camera = (MKLCamera){
        .position = {0, 2, 10},
        .target = {0, 0, 0},
        .up = {0, 1, 0},
        .fov = 45.0f,
        .aspect = 800.0f / 1200.0f,
        .near = 0.1f,
        .far = 100.0f,
        .mode = MKL_CAMERA_FIRST_PERSON
    };
    
    // Optional: Enable lighting
    MKLEnableEnhancedRendering(renderer, true);
    MKLLight sun = MKLCreateDirectionalLight(
        (vector_float3){-1, -1, -1},
        MKL_COLOR_WHITE, 0.8f
    );
    MKLAddLight(renderer, sun);
    
    // Main loop
    while (!MKLWindowShouldClose(window)) {
        float deltaTime = MKLTicks(60) / 1000.0f;
        MKLPollEvents();
        
        // Handle input
        if (MKLIsKeyDown(MKL_KEY_ESCAPE)) {
            MKLSetWindowShouldClose(window, true);
        }
        
        // Update camera
        float speed = 5.0f * deltaTime;
        if (MKLIsKeyDown(MKL_KEY_W)) 
            MKLCameraMoveForward(&renderer->camera, speed, true);
        // ... more movement
        
        MKLUpdateInputState();
        
        // Render
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_MAIN);
        MKLUpdateCamera(&renderer->camera, 0);
        
        // Draw your scene here
        MKLDrawCube(renderer, (MKLCube){
            .position = {0, 1, 0},
            .rotation = {0, 0, 0},
            .width = 2, .height = 2, .depth = 2
        }, MKL_COLOR_RED);
        
        MKLEndDrawing(renderer);
    }
    
    // Cleanup
    MKLClearLights(renderer);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    return 0;
}
```

---

## 🎓 Recommended Learning Order

1. **`01_hello_cube`** (5 min) - Understand basic structure
2. **`01_camera_controls`** (10 min) - Learn navigation  
3. **`02_shapes_demo`** (10 min) - See all primitives, toggle lighting
4. **`03_lighting_demo`** (15 min) - **KEY EXAMPLE** - See lighting effects!
5. **`04_camera_modes`** (15 min) - Master camera systems
6. **`05_instanced_rendering`** (10 min) - Learn optimization
7. **`06_obj_viewer`** (10 min) - Load complex models
8. **`02_custom_shader`** (20 min) - Advanced shader programming

**Total time:** ~1.5 hours to go through all examples

---

## 🔥 Must-See Examples

### 🌟 `03_lighting_demo` - SEE LIGHTING WORK!
The **most impressive** example. You'll immediately see:
- Shiny highlights proving lighting works
- Moving blue light affecting nearby cubes
- Press 'L' to toggle and see the difference

**Run it:** `make lights && ./build/bin/03_lighting_demo`

### 🚀 `05_instanced_rendering` - 3,375 CUBES!
Shows the **power of GPU instancing**:
- Thousands of objects in one draw call
- Smooth 60 FPS performance
- Waving animation across all cubes

**Run it:** `make instancing && ./build/bin/05_instanced_rendering`

### 🎥 `04_camera_modes` - ORBITAL AUTO-ROTATE!
Press '3' and watch the camera **automatically orbit** around the scene!

**Run it:** `make camera-modes && ./build/bin/04_camera_modes`

---

## 📦 Assets

**Shared resources:**
- `assets/FinalBaseMesh.obj` - Complex 3D model (97K vertices)
- `02_graphics/shadertoy.metal` - Example custom shader

---

## 🎉 Summary

**8 well-organized examples** covering:
- ✅ Basics (window, camera, rendering)
- ✅ Graphics (shapes, custom shaders)
- ✅ Lighting (multiple lights, specular highlights)
- ✅ Advanced (4 camera modes)
- ✅ Performance (GPU instancing)
- ✅ Models (OBJ loading)

**All examples:**
- Compile without errors
- Run without crashes
- Include helpful comments
- Demonstrate specific features
- Are well-organized and maintainable

**Start here:** `make hello && ./build/bin/01_hello_cube`

Enjoy exploring MKL! 🚀

