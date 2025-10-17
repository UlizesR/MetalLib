#include "MKL.h"
#include <stdio.h>

int main(void) {
    printf("=== Testing Texture API ===\n");
    
    MKLInitTimer();
    MKLWindow *window = MKLCreateWindow(800, 600, "Texture API Test");
    MKLRenderer *renderer = MKLCreateRenderer(window);
    
    if (!window || !renderer) {
        fprintf(stderr, "Failed to initialize\n");
        return -1;
    }
    
    printf("Testing texture generation...\n");
    MKLTexture checker = MKLGenTextureCheckerboard(renderer, 256, 256, 8, 8,
                                                     (vector_float4){1, 1, 1, 1},
                                                     (vector_float4){0, 0, 0, 1});
    
    if (MKLIsTextureValid(&checker)) {
        printf("✓ Checkerboard texture created: %dx%d\n", checker.width, checker.height);
        MKLUnloadTexture(&checker);
        printf("✓ Texture unloaded\n");
    } else {
        printf("✗ Texture creation failed\n");
    }
    
    MKLDestroyRenderer(renderer);
    MKLDestroyWindow(window);
    printf("✓ Test complete\n");
    return 0;
}

