#import "Graphics/Metal/guli_metal.h"
#import "Graphics/Metal/guli_metal_shader.h"

#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

static const char* clear_msl =
    "#include <metal_stdlib>\n"
    "using namespace metal;\n"
    "struct Uniforms { float4 colDiffuse; };\n"
    "struct VertexOut { float4 position [[position]]; float4 color; };\n"
    "vertex VertexOut vertexMain(uint vid [[vertex_id]]) {\n"
    "    float2 positions[3] = { float2(-1,-1), float2(3,-1), float2(-1,3) };\n"
    "    VertexOut out;\n"
    "    out.position = float4(positions[vid], 0.0, 1.0);\n"
    "    out.color = float4(1.0);\n"
    "    return out;\n"
    "}\n"
    "fragment float4 fragmentMain(VertexOut in [[stage_in]], constant Uniforms& u [[buffer(0)]]) {\n"
    "    return u.colDiffuse * in.color;\n"
    "}\n";

static void MetalBeginPass(const GULI_COLOR* clearColor);

static BOOL MetalCreateClearPipeline(struct MetalState* m)
{
    if (!m || !m->_device) return NO;

    NSError* err = nil;
    id<MTLLibrary> lib = [m->_device newLibraryWithSource:@(clear_msl) options:nil error:&err];
    if (!lib)
    {
        NSLog(@"[Guli] Clear pipeline library compile failed: %@", err);
        return NO;
    }

    id<MTLFunction> vs = [lib newFunctionWithName:@"vertexMain"];
    id<MTLFunction> fs = [lib newFunctionWithName:@"fragmentMain"];
    if (!vs || !fs)
    {
        NSLog(@"[Guli] Clear pipeline functions missing.");
        return NO;
    }

    MTLRenderPipelineDescriptor* desc = [MTLRenderPipelineDescriptor new];
    desc.label = @"guli.clear.pipeline";
    desc.vertexFunction = vs;
    desc.fragmentFunction = fs;
    desc.colorAttachments[0].pixelFormat = m->_colorFormat;

    m->_clearPipeline = [m->_device newRenderPipelineStateWithDescriptor:desc error:&err];
    if (!m->_clearPipeline)
    {
        NSLog(@"[Guli] Clear pipeline creation failed: %@", err);
        return NO;
    }

    // 16 bytes = float4
    m->_clearUniformBuffer = [m->_device newBufferWithLength:16 options:MTLResourceStorageModeShared];
    m->_clearUniformBuffer.label = @"guli.clear.uniforms";
    return (m->_clearUniformBuffer != nil);
}

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

    // Only allocate depth/MSAA if enabled.
    const BOOL useMSAA  = (m->_sampleCount > 1);
    const BOOL useDepth = m->_useDepth;

    if (useMSAA)
    {
        MTLTextureDescriptor* msaaDesc =
            [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:m->_colorFormat
                                                              width:(NSUInteger)w
                                                             height:(NSUInteger)h
                                                          mipmapped:NO];
        msaaDesc.textureType  = MTLTextureType2DMultisample;
        msaaDesc.sampleCount  = m->_sampleCount;
        msaaDesc.usage        = MTLTextureUsageRenderTarget;
        msaaDesc.storageMode  = MTLStorageModePrivate;
        m->_msaaColor = [m->_device newTextureWithDescriptor:msaaDesc];
        m->_msaaColor.label = @"guli.msaa.color";
    }
    else
    {
        m->_msaaColor = nil;
    }

    if (useDepth)
    {
        MTLTextureDescriptor* depthDesc =
            [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:m->_depthFormat
                                                              width:(NSUInteger)w
                                                             height:(NSUInteger)h
                                                          mipmapped:NO];
        depthDesc.textureType = useMSAA ? MTLTextureType2DMultisample : MTLTextureType2D;
        depthDesc.sampleCount = useMSAA ? m->_sampleCount : 1;
        depthDesc.usage       = MTLTextureUsageRenderTarget;
        depthDesc.storageMode = MTLStorageModePrivate;
        m->_depth = [m->_device newTextureWithDescriptor:depthDesc];
        m->_depth.label = @"guli.depth";
    }
    else
    {
        m->_depth = nil;
    }
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

    metal_s->_colorFormat  = MTLPixelFormatBGRA8Unorm;

    // For this engine’s fullscreen effects, default to NO depth.
    metal_s->_useDepth     = NO;
    metal_s->_depthFormat  = MTLPixelFormatDepth32Float;

    metal_s->_sampleCount  = 1;

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

    if (!MetalCreateClearPipeline(metal_s))
    {
        err_msg = "Failed to create clear pipeline";
        goto fail;
    }

    state->metal_s = metal_s;
    GuliSetError(&state->error, GULI_ERROR_SUCCESS, NULL);
    return GULI_ERROR_SUCCESS;

fail:
    if (state) GuliSetError(&state->error, GULI_ERROR_FAILED, err_msg);
    GULI_PRINT_ERROR(GULI_ERROR_FAILED, err_msg);
    if (metal_s) free(metal_s);
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
    m->_clearPipeline = nil;
    m->_clearUniformBuffer = nil;

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

void MetalBeginDraw(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m) return;

    @autoreleasepool
    {
        dispatch_semaphore_wait(m->_inflightSemaphore, DISPATCH_TIME_FOREVER);

        MetalUpdateDrawableSizeAndAttachments();

        m->_cmd = [m->_commandQueue commandBuffer];
        m->_cmd.label = @"guli.frame.cmd";

        dispatch_semaphore_t sema = m->_inflightSemaphore;
        [m->_cmd addCompletedHandler:^(__unused id<MTLCommandBuffer> cb) {
            dispatch_semaphore_signal(sema);
        }];

        // Start pass with "dontCare"; user may call MetalClearColor to clear via draw.
        MetalBeginPass(NULL);
    }
}

static void MetalBeginPass(const GULI_COLOR* clearColor)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_cmd) return;

    // Acquire drawable as late as possible.
    id<CAMetalDrawable> drawable = [m->_layer nextDrawable];
    if (!drawable) return;

    m->_drawable = drawable;

    const NSUInteger slot = (m->_frameIndex++) % GULI_MAX_FRAMES_IN_FLIGHT;
    MTLRenderPassDescriptor* pass = m->_onscreenPassDesc[slot];

    // Color attachment
    if (clearColor)
    {
        pass.colorAttachments[0].loadAction = MTLLoadActionClear;
        pass.colorAttachments[0].clearColor = MTLClearColorMake(
            (double)(*clearColor)[0], (double)(*clearColor)[1],
            (double)(*clearColor)[2], (double)(*clearColor)[3]);
    }
    else
    {
        // We either clear via MetalClearColor draw, or fully overwrite anyway:
        pass.colorAttachments[0].loadAction = MTLLoadActionDontCare; // avoid tile loads :contentReference[oaicite:9]{index=9}
    }

    if (m->_sampleCount > 1 && m->_msaaColor)
    {
        pass.colorAttachments[0].texture = m->_msaaColor;
        pass.colorAttachments[0].resolveTexture = m->_drawable.texture;
        pass.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
    }
    else
    {
        pass.colorAttachments[0].texture = m->_drawable.texture;
        pass.colorAttachments[0].resolveTexture = nil;
        pass.colorAttachments[0].storeAction = MTLStoreActionStore; // needed for present
    }

    // Depth optional
    if (m->_useDepth && m->_depth)
    {
        pass.depthAttachment.texture = m->_depth;
        pass.depthAttachment.loadAction = MTLLoadActionClear;
        pass.depthAttachment.clearDepth = 1.0;
        pass.depthAttachment.storeAction = MTLStoreActionDontCare;
    }
    else
    {
        pass.depthAttachment.texture = nil;
    }

    m->_enc = [m->_cmd renderCommandEncoderWithDescriptor:pass];
    m->_enc.label = @"guli.frame.enc";
}

static void MetalEndPass(void)
{
    struct MetalState* m = G_State.metal_s;
    if (m && m->_enc)
    {
        [m->_enc endEncoding];
        m->_enc = nil;
    }
}

void MetalEndDraw(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_cmd) return;

    @autoreleasepool
    {
        MetalEndPass();

        if (m->_drawable)
        {
            [m->_cmd presentDrawable:m->_drawable];
        }

        [m->_cmd commit];

        // Release references quickly (drawable lifetime best practice) :contentReference[oaicite:10]{index=10}
        m->_drawable = nil;
        m->_cmd = nil;
    }
}

int MetalHasActiveFrame(void)
{
    struct MetalState* m = G_State.metal_s;
    return (m && m->_cmd != nil) ? 1 : 0;
}

void MetalClearColor(GULI_COLOR color)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_enc || !m->_clearPipeline) return;

    float* ptr = (float*)m->_clearUniformBuffer.contents;
    ptr[0] = color[0]; ptr[1] = color[1]; ptr[2] = color[2]; ptr[3] = color[3];

    [m->_enc setRenderPipelineState:m->_clearPipeline];
    [m->_enc setFragmentBuffer:m->_clearUniformBuffer offset:0 atIndex:0];
    [m->_enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
}

void MetalDrawFullscreen(void)
{
    struct MetalState* m = G_State.metal_s;
    if (!m || !m->_enc) return;

    [m->_enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
}
