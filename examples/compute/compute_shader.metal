//
// compute_shader.metal
// Simple compute shader for array addition
//

#include <metal_stdlib>
using namespace metal;

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

// Example: Parallel multiplication
kernel void vector_multiply(
    device const float* inputA [[buffer(0)]],
    device const float* inputB [[buffer(1)]],
    device float* output [[buffer(2)]],
    constant int& arraySize [[buffer(3)]],
    uint gid [[thread_position_in_grid]])
{
    if (gid >= arraySize) return;
    output[gid] = inputA[gid] * inputB[gid];
}

// Example: Dot product reduction (simple version)
kernel void vector_dot(
    device const float* inputA [[buffer(0)]],
    device const float* inputB [[buffer(1)]],
    device float* partialSums [[buffer(2)]],
    constant int& arraySize [[buffer(3)]],
    uint gid [[thread_position_in_grid]])
{
    if (gid >= arraySize) return;
    partialSums[gid] = inputA[gid] * inputB[gid];
}
