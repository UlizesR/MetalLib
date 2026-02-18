#import "Graphics/Metal/guli_metal.h"

#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

void MetalInit(GuliState* state)
{
    struct MetalState* metal_s = NULL;
    NSWindow* nswindow = nil;
    const char* err_msg = NULL;

    if (!state)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to initialize Metal: state is NULL");
        return;
    }

    metal_s = calloc(1, sizeof(struct MetalState));
    if (!metal_s) { err_msg = "Failed to allocate memory for Metal state"; goto fail; }

    metal_s->_device = MTLCreateSystemDefaultDevice();
    if (!metal_s->_device) { err_msg = "Failed to create Metal device"; goto fail; }

    metal_s->_commandQueue = [metal_s->_device newCommandQueue];
    if (!metal_s->_commandQueue) { err_msg = "Failed to create Metal command queue"; goto fail; }

    metal_s->_layer = [CAMetalLayer layer];
    if (!metal_s->_layer) { err_msg = "Failed to create Metal layer"; goto fail; }

    metal_s->_layer.device = metal_s->_device;
    metal_s->_layer.pixelFormat = MTLPixelFormatBGRA8Unorm;

    nswindow = glfwGetCocoaWindow(state->window);
    if (!nswindow) { err_msg = "Failed to get NSWindow"; goto fail; }

    nswindow.contentView.layer = metal_s->_layer;
    nswindow.contentView.wantsLayer = YES;

    state->metal_s = metal_s;
    return;

fail:
    if (state) GuliSetError(&state->error, GULI_ERROR_FAILED, err_msg);
    GULI_PRINT_ERROR(GULI_ERROR_FAILED, err_msg);
    free(metal_s);
}   

void MetalShutdown(GuliState* state)
{
    if (!state)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to shutdown Metal: state is NULL");
        return;
    }
    if (!state->metal_s)
    {
        GULI_FAIL_RETURN(state, GULI_ERROR_FAILED, "Failed to shutdown Metal: metal_s is NULL");
    }

    state->metal_s->_layer = nil;
    state->metal_s->_commandQueue = nil;
    state->metal_s->_device = nil;
    free(state->metal_s);
    state->metal_s = nil;

    if (state) GuliSetError(&state->error, GULI_ERROR_SUCCESS, NULL);
}

void MetalClearColor(GULI_COLOR color)
{
    if (!G_State.metal_s) return;

    id<CAMetalDrawable> drawable = [G_State.metal_s->_layer nextDrawable];
    if (!drawable) return;

    MTLRenderPassDescriptor* passDesc = [MTLRenderPassDescriptor renderPassDescriptor];
    passDesc.colorAttachments[0].texture = drawable.texture;
    passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDesc.colorAttachments[0].clearColor = MTLClearColorMake(
        (double)color[0], (double)color[1], (double)color[2], (double)color[3]);

    id<MTLCommandBuffer> cmdBuf = [G_State.metal_s->_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [cmdBuf renderCommandEncoderWithDescriptor:passDesc];
    [encoder endEncoding];
    [cmdBuf presentDrawable:drawable];
    [cmdBuf commit];
}
