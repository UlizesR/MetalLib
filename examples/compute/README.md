# MKL Compute Shader Example

This example demonstrates GPU compute shader capabilities in MetalLib for parallel processing and GPGPU tasks.

## What it Does

- Performs parallel vector addition on 1024 elements using Metal compute shaders
- Demonstrates buffer creation, data upload, and GPU dispatch
- Shows how to read results back from GPU memory
- Achieves massive parallelization (all 1024 operations run simultaneously)

## Features Demonstrated

- **Compute Shader Loading**: `MKLLoadComputeShader()`
- **Buffer Management**: Create, upload, and read GPU buffers
- **Parallel Dispatch**: Automatic threadgroup optimization
- **Synchronization**: Wait for GPU completion
- **Performance Timing**: Measure GPU execution time

## Building and Running

```bash
cd build
make -j8
./bin/compute_compute_example
```

## Expected Output

```
=== MKL Compute Shader Example ===

✓ Metal device initialized
✓ Compute shader loaded
  Max threads per threadgroup: 1024
  Thread execution width: 32

Input arrays initialized (1024 elements)
✓ GPU buffers created
Dispatching compute work...
✓ Compute completed in 0.2 ms

Verifying results...
✅ All 1024 results are correct!

Sample results:
  [0] 0 + 1024 = 1024
  [1] 1 + 1023 = 1024
  ...
```

## Use Cases

Compute shaders are perfect for:
- **Data Processing**: Image filters, audio processing
- **Physics Simulations**: Particle systems, fluid dynamics
- **Scientific Computing**: Matrix operations, signal processing
- **Machine Learning**: Neural network inference
- **Parallel Algorithms**: Sorting, searching, reductions

## The Metal Shader

The compute shader (`compute_shader.metal`) is remarkably simple:

```metal
kernel void vector_add(
    device const float* inputA [[buffer(0)]],
    device const float* inputB [[buffer(1)]],
    device float* output [[buffer(2)]],
    constant int& arraySize [[buffer(3)]],
    uint gid [[thread_position_in_grid]])
{
    if (gid >= arraySize) return;
    output[gid] = inputA[gid] + inputB[gid];
}
```

Each GPU thread processes one element in parallel!

## API Overview

### 1. Load Compute Shader
```c
MKLComputeShader *shader = MKLLoadComputeShader(
    renderer, 
    "compute_shader.metal", 
    "vector_add"
);
```

### 2. Create Buffers
```c
MKLComputeBuffer bufferA = MKLCreateComputeBufferWithData(
    renderer, data, size, MKL_COMPUTE_BUFFER_READ
);
```

### 3. Set Parameters
```c
MKLSetComputeBuffer(shader, &bufferA, 0);
MKLSetComputeInt(shader, arraySize, 3);
```

### 4. Dispatch
```c
MKLDispatchCompute(shader, ARRAY_SIZE, 1, 1);
MKLWaitForComputeCompletion(shader);
```

### 5. Read Results
```c
MKLReadComputeBuffer(&bufferOutput, output, size, 0);
```

## Performance

On Apple Silicon, this example can process 1024 elements in **< 1 millisecond**, demonstrating the massive parallelization power of GPU compute shaders.

---

**Perfect for:** GPGPU programming, parallel algorithms, high-performance computing
