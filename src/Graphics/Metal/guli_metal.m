#import "Graphics/Metal/guli_metal.h"

#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

static void MetalUpdateDrawableSizeAndAttachments(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m) return;

    int w = 0, h = 0;
    GuliGetFramebufferSize(&w, &h);
    if (w <= 0 || h <= 0) return;

    CGSize sz = CGSizeMake((CGFloat)w, (CGFloat)h);
    if (CGSizeEqualToSize(sz, m->_drawableSize)) return;

    m->_drawableSize = sz;
    m->_layer.drawableSize = sz;

    const BOOL useMSAA = (m->_sampleCount > 1);

    if (useMSAA) 
    {
        MTLTextureDescriptor* msaaDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:m->_colorFormat
                                                                                            width:(NSUInteger)w
                                                                                           height:(NSUInteger)h
                                                                                        mipmapped:NO];
        msaaDesc.textureType = MTLTextureType2DMultisample;
        msaaDesc.sampleCount = m->_sampleCount;
        msaaDesc.usage = MTLTextureUsageRenderTarget;
        msaaDesc.storageMode = MTLStorageModePrivate;
        m->_msaaColor = [m->_device newTextureWithDescriptor:msaaDesc];
    } else {
        m->_msaaColor = nil;
    }

    MTLTextureDescriptor* depthDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:m->_depthFormat
                                                                                         width:(NSUInteger)w
                                                                                        height:(NSUInteger)h
                                                                                     mipmapped:NO];
    depthDesc.textureType = useMSAA ? MTLTextureType2DMultisample : MTLTextureType2D;
    depthDesc.sampleCount = useMSAA ? m->_sampleCount : 1;
    depthDesc.usage = MTLTextureUsageRenderTarget;
    depthDesc.storageMode = MTLStorageModePrivate;
    m->_depth = [m->_device newTextureWithDescriptor:depthDesc];
}

GULIResult MetalInit(GuliState* state)
{
    struct MetalState* metal_s = NULL;
    NSWindow* nswindow = nil;
    const char* err_msg = NULL;

    if (!state)
    {
        GULI_PRINT_ERROR(GULI_ERROR_FAILED, "Failed to initialize Metal: state is NULL");
        return GULI_ERROR_FAILED;
    }

    metal_s = calloc(1, sizeof(struct MetalState));
    if (!metal_s) { err_msg = "Failed to allocate memory for Metal state"; goto fail; }

    metal_s->_device = MTLCreateSystemDefaultDevice();
    if (!metal_s->_device) { err_msg = "Failed to create Metal device"; goto fail; }

    metal_s->_commandQueue = [metal_s->_device newCommandQueue];
    if (!metal_s->_commandQueue) { err_msg = "Failed to create Metal command queue"; goto fail; }

    metal_s->_layer = [CAMetalLayer layer];
    if (!metal_s->_layer) { err_msg = "Failed to create Metal layer"; goto fail; }

    metal_s->_colorFormat = MTLPixelFormatBGRA8Unorm;
    metal_s->_depthFormat = MTLPixelFormatDepth32Float;
    metal_s->_sampleCount = 1;

    metal_s->_layer.device = metal_s->_device;
    metal_s->_layer.pixelFormat = metal_s->_colorFormat;
    metal_s->_layer.framebufferOnly = YES;
    metal_s->_layer.opaque = YES;

    metal_s->_inflightSemaphore = dispatch_semaphore_create(GULI_MAX_FRAMES_IN_FLIGHT);
    metal_s->_frameIndex = 0;

    for (NSUInteger i = 0; i < GULI_MAX_FRAMES_IN_FLIGHT; ++i)
    {
        metal_s->_onscreenPassDesc[i] = [MTLRenderPassDescriptor renderPassDescriptor];
    }

    nswindow = glfwGetCocoaWindow(state->window);
    if (!nswindow) { err_msg = "Failed to get NSWindow"; goto fail; }

    nswindow.contentView.layer = metal_s->_layer;
    nswindow.contentView.wantsLayer = YES;

    state->metal_s = metal_s;
    GuliSetError(&state->error, GULI_ERROR_SUCCESS, NULL);
    return GULI_ERROR_SUCCESS;

fail:
    if (state) GuliSetError(&state->error, GULI_ERROR_FAILED, err_msg);
    GULI_PRINT_ERROR(GULI_ERROR_FAILED, err_msg);
    free(metal_s);
    return GULI_ERROR_FAILED;
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
        return;
    }

    struct MetalState* m = state->metal_s;

    m->_drawable = nil;
    m->_enc = nil;
    m->_cmd = nil;
    m->_msaaColor = nil;
    m->_depth = nil;

    for (NSUInteger i = 0; i < GULI_MAX_FRAMES_IN_FLIGHT; ++i)
    {
        m->_onscreenPassDesc[i] = nil;
    }

    m->_inflightSemaphore = nil;
    m->_layer = nil;
    m->_commandQueue = nil;
    m->_device = nil;

    free(state->metal_s);
    state->metal_s = nil;

    GuliSetError(&state->error, GULI_ERROR_SUCCESS, "Metal shutdown successfully");
}

void MetalBeginFrame(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m) return;

    dispatch_semaphore_wait(m->_inflightSemaphore, DISPATCH_TIME_FOREVER);
    MetalUpdateDrawableSizeAndAttachments();

    m->_cmd = [m->_commandQueue commandBuffer];

    dispatch_semaphore_t sema = m->_inflightSemaphore;
    [m->_cmd addCompletedHandler:^(__unused id<MTLCommandBuffer> cb) { dispatch_semaphore_signal(sema); }];
}

void MetalBeginPass(GULI_COLOR clearColor, double clearDepth)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_cmd) return;

    m->_drawable = [m->_layer nextDrawable];
    if (!m->_drawable) return;

    const NSUInteger slot = (m->_frameIndex++) % GULI_MAX_FRAMES_IN_FLIGHT;
    MTLRenderPassDescriptor* pass = m->_onscreenPassDesc[slot];

    pass.colorAttachments[0].loadAction = MTLLoadActionClear;
    pass.colorAttachments[0].clearColor = MTLClearColorMake(
        (double)clearColor[0], (double)clearColor[1],
        (double)clearColor[2], (double)clearColor[3]);

    if (m->_sampleCount > 1 && m->_msaaColor)
    {
        pass.colorAttachments[0].texture = m->_msaaColor;
        pass.colorAttachments[0].resolveTexture = m->_drawable.texture;
        pass.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
    } else {
        pass.colorAttachments[0].texture = m->_drawable.texture;
        pass.colorAttachments[0].resolveTexture = nil;
        pass.colorAttachments[0].storeAction = MTLStoreActionStore;
    }

    if (m->_depth)
    {
        pass.depthAttachment.texture = m->_depth;
        pass.depthAttachment.loadAction = MTLLoadActionClear;
        pass.depthAttachment.clearDepth = clearDepth;
        pass.depthAttachment.storeAction = MTLStoreActionDontCare;
    } else {
        pass.depthAttachment.texture = nil;
    }

    m->_enc = [m->_cmd renderCommandEncoderWithDescriptor:pass];
}

void MetalEndPass(void)
{
    struct MetalState* m = G_State.metal_s;
    if (m && m->_enc)
    {
        [m->_enc endEncoding];
        m->_enc = nil;
    }
}

void MetalEndFrame(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_cmd) return;

    MetalEndPass();

    if (m->_drawable)
    {
        [m->_cmd presentDrawable:m->_drawable];
    }
    [m->_cmd commit];

    m->_drawable = nil;
    m->_cmd = nil;
}

int MetalHasActiveFrame(void)
{
    struct MetalState* m = G_State.metal_s;
    return (m && m->_cmd != nil) ? 1 : 0;
}

void MetalClearColor(GULI_COLOR color)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_cmd) return;

    MetalBeginPass(color, 1.0);
    MetalEndPass();
}
