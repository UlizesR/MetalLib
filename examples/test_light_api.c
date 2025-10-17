#include "MKL.h"
#include <stdio.h>

int main(void) {
    printf("=== Testing Light API ===\n");
    
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(800, 600, "Light API Test");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize\n");
        return -1;
    }
    
    printf("Testing light creation...\n");
    
    MKLLight ambient = MKLCreateAmbientLight(MKL_COLOR_WHITE, 0.2f);
    int idx1 = MKLAddLight(renderer, ambient);
    printf("✓ Ambient light added at index %d\n", idx1);
    
    MKLLight sun = MKLCreateDirectionalLight((vector_float3){-1, -1, -1}, MKL_COLOR_WHITE, 0.8f);
    int idx2 = MKLAddLight(renderer, sun);
    printf("✓ Directional light added at index %d\n", idx2);
    
    MKLLight point = MKLCreatePointLight((vector_float3){0, 2, 0}, MKL_COLOR_BLUE, 2.0f, 10.0f);
    int idx3 = MKLAddLight(renderer, point);
    printf("✓ Point light added at index %d\n", idx3);
    
    printf("Total lights: %d\n", MKLGetLightCount(renderer));
    
    MKLLight *retrieved = MKLGetLight(renderer, idx3);
    if (retrieved) {
        printf("✓ Retrieved light at index %d: pos(%.2f, %.2f, %.2f)\n", 
               idx3, retrieved->position.x, retrieved->position.y, retrieved->position.z);
    }
    
    MKLClearLights(renderer);
    printf("✓ Lights cleared, remaining: %d\n", MKLGetLightCount(renderer));
    
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Test complete\n");
    return 0;
}

