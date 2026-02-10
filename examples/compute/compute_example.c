//
// compute_example.c
// Compute Shader Example - Array Processing with Metal Compute
//
// Demonstrates:
// - Loading compute shaders with MKLLoadComputeShader()
// - Creating and managing compute buffers
// - Dispatching parallel compute work on GPU
// - Reading results back from GPU memory
// - Simple array addition performed in parallel
//
// This example showcases MKL's compute shader capabilities for GPGPU tasks
// like data processing, physics simulations, and parallel algorithms.
//

#include "MKL.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define ARRAY_SIZE 1024

int main(void) {
    printf("=== MKL Compute Shader Example ===\n\n");

    // Initialize timer
    MKLInitTimer();

    // Create minimal window and renderer (needed for Metal device access)
    MKLWindow *window = MKLCreateWindow(800, 600, "MKL - Compute Shader Example");
    if (!window) {
        fprintf(stderr, "❌ Failed to create window\n");
        return 1;
    }

    MKLRenderer *renderer = MKLCreateRenderer(window);
    if (!renderer) {
        fprintf(stderr, "❌ Failed to create renderer\n");
        MKLDestroyWindow(window);
        return 1;
    }

    printf("✓ Metal device initialized\n");

    // Load compute shader
    MKLComputeShader *computeShader = MKLLoadComputeShader(
        renderer,
        "compute_shader.metal",
        "vector_add"
    );

    if (!MKLIsComputeShaderValid(computeShader)) {
        fprintf(stderr, "❌ Failed to load compute shader\n");
        MKLDestroyRenderer(renderer);
        MKLDestroyWindow(window);
        return 1;
    }

    printf("✓ Compute shader loaded\n");
    printf("  Max threads per threadgroup: %zu\n", MKLGetMaxThreadsPerThreadgroup(computeShader));
    printf("  Thread execution width: %zu\n\n", MKLGetThreadExecutionWidth(computeShader));

    // Prepare input data
    float *inputA = (float *)malloc(ARRAY_SIZE * sizeof(float));
    float *inputB = (float *)malloc(ARRAY_SIZE * sizeof(float));
    float *output = (float *)malloc(ARRAY_SIZE * sizeof(float));

    if (!inputA || !inputB || !output) {
        fprintf(stderr, "❌ Failed to allocate memory\n");
        MKLUnloadComputeShader(computeShader);
        MKLDestroyRenderer(renderer);
        MKLDestroyWindow(window);
        return 1;
    }

    // Initialize input arrays
    for (int i = 0; i < ARRAY_SIZE; i++) {
        inputA[i] = (float)i;
        inputB[i] = (float)(ARRAY_SIZE - i);
    }

    printf("Input arrays initialized (%d elements)\n", ARRAY_SIZE);

    // Create GPU buffers
    MKLComputeBuffer bufferA = MKLCreateComputeBufferWithData(
        renderer, inputA, ARRAY_SIZE * sizeof(float), MKL_COMPUTE_BUFFER_READ
    );

    MKLComputeBuffer bufferB = MKLCreateComputeBufferWithData(
        renderer, inputB, ARRAY_SIZE * sizeof(float), MKL_COMPUTE_BUFFER_READ
    );

    MKLComputeBuffer bufferOutput = MKLCreateComputeBuffer(
        renderer, ARRAY_SIZE * sizeof(float), MKL_COMPUTE_BUFFER_WRITE
    );

    if (!MKLIsComputeBufferValid(&bufferA) ||
        !MKLIsComputeBufferValid(&bufferB) ||
        !MKLIsComputeBufferValid(&bufferOutput)) {
        fprintf(stderr, "❌ Failed to create compute buffers\n");
        free(inputA);
        free(inputB);
        free(output);
        MKLUnloadComputeShader(computeShader);
        MKLDestroyRenderer(renderer);
        MKLDestroyWindow(window);
        return 1;
    }

    printf("✓ GPU buffers created\n");

    // Set buffers for compute shader
    MKLSetComputeBuffer(computeShader, &bufferA, 0);      // [[buffer(0)]]
    MKLSetComputeBuffer(computeShader, &bufferB, 1);      // [[buffer(1)]]
    MKLSetComputeBuffer(computeShader, &bufferOutput, 2); // [[buffer(2)]]

    // Set array size parameter
    int arraySize = ARRAY_SIZE;
    MKLSetComputeInt(computeShader, arraySize, 3);        // [[buffer(3)]]

    printf("Dispatching compute work...\n");

    // Dispatch compute shader
    double startTime = MKLGetTime();
    MKLDispatchCompute(computeShader, ARRAY_SIZE, 1, 1);
    MKLWaitForComputeCompletion(computeShader);
    double endTime = MKLGetTime();

    printf("✓ Compute completed in %.4f ms\n", (endTime - startTime) * 1000.0);

    // Read results back from GPU
    MKLReadComputeBuffer(&bufferOutput, output, ARRAY_SIZE * sizeof(float), 0);

    printf("\nVerifying results...\n");

    // Verify results
    bool allCorrect = true;
    int errorCount = 0;
    for (int i = 0; i < ARRAY_SIZE; i++) {
        float expected = inputA[i] + inputB[i];
        if (fabs(output[i] - expected) > 0.001f) {
            if (errorCount < 5) { // Only print first 5 errors
                printf("  Error at index %d: expected %.2f, got %.2f\n",
                       i, expected, output[i]);
            }
            errorCount++;
            allCorrect = false;
        }
    }

    if (allCorrect) {
        printf("✅ All %d results are correct!\n", ARRAY_SIZE);
        printf("\nSample results:\n");
        for (int i = 0; i < 5; i++) {
            printf("  [%d] %.0f + %.0f = %.0f\n",
                   i, inputA[i], inputB[i], output[i]);
        }
        printf("  ...\n");
        for (int i = ARRAY_SIZE - 5; i < ARRAY_SIZE; i++) {
            printf("  [%d] %.0f + %.0f = %.0f\n",
                   i, inputA[i], inputB[i], output[i]);
        }
    } else {
        printf("❌ Found %d errors in results\n", errorCount);
    }

    // Cleanup
    printf("\n🧹 Cleaning up...\n");
    MKLReleaseComputeBuffer(&bufferA);
    MKLReleaseComputeBuffer(&bufferB);
    MKLReleaseComputeBuffer(&bufferOutput);
    MKLUnloadComputeShader(computeShader);
    free(inputA);
    free(inputB);
    free(output);
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Cleanup complete!\n");

    return allCorrect ? 0 : 1;
}

