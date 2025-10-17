# MetalLib (MKL)

A modern, high-performance graphics library for macOS using the Metal API. Built with C and Objective-C, MKL provides a simple and intuitive API inspired by raylib for creating 3D graphics applications.

## ✨ Features

- 🎮 **Simple API** - Raylib-inspired design for ease of use
- 🚀 **High Performance** - Optimized Metal rendering pipeline
  - Triple buffering for CPU/GPU parallelism
  - Efficient buffer pooling
  - SIMD-accelerated math operations
- 🎨 **Custom Shaders** - Load and use Metal shaders at runtime
- 🪟 **Modern Window System** - GLFW-inspired window management
  - Resizable, fullscreen, decorated windows
  - Advanced input handling (keyboard, mouse)
  - Event polling and callbacks
- 📦 **No App Bundle Required** - Build simple executables without code signing
- 🎯 **3D Primitives** - Cubes, spheres, cylinders, cones, torus, planes, and custom meshes
- 🎨 **2D Shapes** - Circles, rectangles, triangles, polygons, and lines
- 📁 **OBJ File Support** - Load and render 3D models from OBJ files using Model I/O
- 🎭 **Camera System** - First-person and orbital camera controls
- 🖼️ **Texture System** - Load PNG/JPG images, generate procedural textures
- 💡 **Lighting System** - Ambient, directional, and point lights with Blinn-Phong shading
- 🎨 **Material System** - PBR and standard materials with texture mapping support
- 📝 **Text Rendering API** - Font loading and text drawing (implementation in progress)
- 🎬 **Animation API** - Skeletal animation support (implementation in progress)
- 🎯 **Render Targets API** - Off-screen rendering for post-processing (implementation in progress)

## 🚀 Quick Start

### Prerequisites

- macOS 10.13+ (High Sierra or later)
- Xcode Command Line Tools
- Clang compiler with Metal support

### Building

```bash
# Clone the repository
git clone https://github.com/yourusername/MetalLib.git
cd MetalLib

# Build the library and example
make clean && make

# Run the example (from project root)
./bin/ex1
```

### Hello Cube Example

```c
#include "MKL.h"

int main(void) {
    // Initialize
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(800, 600, "Hello Cube");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    // Setup camera
    renderer->camera.position = (vector_float3){0, 2, 5};
    renderer->camera.forward = (vector_float3){0, 0, -1};
    renderer->camera.up = (vector_float3){0, 1, 0};
    
    // Main loop
    while (MKLWindowShouldClose(window)) {
        MKLPollEvents();
        MKLBeginDrawing(renderer);
        MKLClearRenderer(renderer, MKL_COLOR_MAIN);
        
        // Draw a rotating cube
        static float rotation = 0.0f;
        rotation += MKLTicks(60) * 50.0f;
        
        MKLDrawCube(renderer,
                    (MKLCube){
                        .position = {0, 0, 0},
                        .dimensions = {1, 1, 1},
                        .rotation = {0, rotation, 0}
                    },
                    MKL_COLOR_BLUE);
        
        MKLEndDrawing(renderer);
        MKLUpdateInputState();
    }
    
    // Cleanup
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    return 0;
}
```

## 📚 Documentation

- [API Reference](docs/API.md) - Complete API documentation (coming soon)

## 🎯 Examples

### Basic Example (included)
```bash
make && ./bin/ex1
```

### ShaderToy Example
```bash
make shadertoy && ./bin/shadertoy
```

### Shapes Demo
```bash
make shapes && ./bin/shapes
```

**Controls:**
- Left-click & drag to look around
- WASD to move camera
- ESC to exit

### Waving Cubes Demo (Instanced Rendering) ⚡
```bash
make waving && ./bin/waving
```

Renders **3,375 cubes** with a waving animation using GPU instanced rendering at **60+ FPS**! This demonstrates the massive performance benefits of drawing thousands of objects in a single draw call.

**Features:**
- True GPU instancing with per-instance transforms
- Rainbow color effect based on position
- Smooth waving animation
- Automatic camera orbit
- Stable memory usage

### OBJ Model Viewer 📁
```bash
make obj && ./bin/obj_viewer
```

Loads and displays 3D models from OBJ files using Model I/O. Includes a sample mesh with **24,461 vertices**.

**Controls:**
- Left-click & drag to look around
- WASD to move camera
- Space/Q to move up/down
- ESC to exit

### Lighting Demo 💡 **NEW!** ✨
```bash
make lighting && ./bin/lighting
```

Demonstrates **REAL-TIME LIGHTING with VISIBLE SPECULAR HIGHLIGHTS!** Shows 15 cubes with dynamic lighting, reflective surfaces, and animated point light movement.

**Visual Effects:**
- ✨ **Specular highlights** (shiny reflections on cube edges)
- 🌞 **Directional shading** (bright and dark sides)
- 💡 **Dynamic point light** with blue tint and attenuation
- 🌑 **Ambient occlusion** for realistic base lighting

**Features:**
- Ambient, directional, and point lights
- Blinn-Phong shading model with real normals
- Animated point light circling the scene
- Toggle enhanced rendering on/off with 'L' key (SEE THE DIFFERENCE!)

**Controls:**
- WASD to move camera
- Mouse drag to look around
- Space/Q to move up/down
- **L to toggle lighting** (watch the highlights appear/disappear!)
- ESC to exit

**TIP:** Press 'L' to toggle lighting off, then on again - the difference is dramatic!

### New Features Demo 🎨 **NEW!**
```bash
make features && ./bin/features
```

Showcases the new API features including textures, lighting, and materials. Demonstrates procedural texture generation and material creation.

### API Tests
```bash
# Test texture system
make test-texture && ./bin/test_texture_api

# Test lighting system
make test-light && ./bin/test_light_api
```

## 🏗️ Project Structure

```
MetalLib/
├── MKL/                    # Core library
│   └── src/
│       ├── Core/           # Timer, error handling
│       ├── Input/          # Keyboard, mouse, input system
│       ├── Math/           # Vector/matrix operations
│       ├── Graphics/       # Rendering, shaders, objects
│       └── MKL.h          # Main header
├── App/                    # Example applications
│   ├── main.c             # Basic example
│   ├── test_shadertoy.c   # ShaderToy example
│   ├── test_shapes.c      # Shapes rendering demo
│   └── shadertoy.metal    # ShaderToy Metal shader
├── bin/                    # Build output
│   ├── libmkl.dylib       # Dynamic library
│   └── ex1                # Executable
└── Makefile               # Build system
```

## 🔧 Building Custom Projects

### Using MKL as a Library

```bash
# Build your project
clang -std=c11 \
      -I./MKL/src \
      -L./bin \
      -lmkl \
      -rpath @executable_path \
      -framework Cocoa \
      -framework Metal \
      -framework MetalKit \
      -framework QuartzCore \
      -framework ModelIO \
      your_code.c -o your_app

# Run (from project root)
./bin/your_app
```

### Makefile Integration

```makefile
APP_NAME = myapp
APP_LINKERS = -L./bin -lmkl -rpath @executable_path \
              -framework Cocoa -framework Metal -framework MetalKit \
              -framework QuartzCore -framework ModelIO

$(APP_NAME): buildLib
	clang $(APP_LINKERS) myapp.c -o bin/$(APP_NAME)
```

## 🎨 Key Features

### Custom Metal Shaders
Load and use custom Metal shaders at runtime with a simple API:

```c
MKLShader *shader = MKLLoadShader(renderer, 
                                   "shader.metal",
                                   "vertexFunc",
                                   "fragmentFunc");

MKLBeginShaderMode(renderer, shader);
MKLSetShaderFloat(shader, "time", currentTime);
MKLDrawCube(renderer, cube, MKL_COLOR_WHITE);
MKLEndShaderMode(renderer);
```

### Window Management
Full control over window properties:

```c
MKLSetWindowResizable(window, true);
MKLSetWindowFullscreen(window, true);
MKLSetWindowOpacity(window, 0.9f);
MKLSetWindowPosition(window, 100, 100);
```

### Input Handling
Modern input system with state tracking:

```c
MKLPollEvents();

if (MKLIsKeyDown(MKL_KEY_W)) {
    // Move forward
}

if (MKLIsMouseButtonPressed(MKL_MOUSE_LEFT)) {
    vector_float2 pos = MKLGetMousePosition();
    // Handle click at pos
}

MKLUpdateInputState();
```

### High-Performance Rendering
- **Triple Buffering** - Smooth frame pacing with CPU/GPU parallelism
- **Buffer Pooling** - Reduced allocations for better performance
- **SIMD Math** - Hardware-accelerated vector/matrix operations
- **Depth Testing** - Proper 3D rendering with depth buffer

## 📊 Performance

MKL is designed for high performance:
- Optimized Metal rendering pipeline
- Minimal CPU overhead
- Efficient memory management
- 60+ FPS on modern Macs with complex scenes

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Inspired by [raylib](https://www.raylib.com/) for the simple API design
- Window system patterns from [GLFW](https://www.glfw.org/)
- Shader examples from [Shadertoy](https://www.shadertoy.com/)
- Metal optimization techniques from Apple's Metal Best Practices

## 🔗 Links

- [Metal Programming Guide](https://developer.apple.com/metal/)
- [SIMD Programming](https://developer.apple.com/documentation/accelerate/simd)
- [Model I/O Framework](https://developer.apple.com/documentation/modelio)

---

**Made with ❤️ for the macOS graphics programming community**
