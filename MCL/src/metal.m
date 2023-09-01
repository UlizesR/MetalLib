#import "MCL/metal.h"
#import "MCL/view.h"
#import "MCL/window.h"

#import <MetalKit/MetalKit.h>

@implementation MTK_Renderer

- (instancetype) initWithMetalView:(MTKView *)metalView 
{
    self = [super init];
    if (self)
    {
      self._device = metalView.device;
      self._commandQueue = [self._device newCommandQueue];

      [self loadMetalShaders];
      [self createRenderPipelineState];
    }
    return self;
}

- (void)loadMetalShaders {
  NSError *error;
  // Load and compile the Metal shaders
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"shaders"
                                                       ofType:@"metal"];
  if (!filePath) {
    [NSException raise:@"Failed to read shaders"
                format:@"%@", [error localizedDescription]];
  }
  NSLog(@"filePath: %@", filePath);
  NSString *librarySrc = [NSString stringWithContentsOfFile:filePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
  if (!librarySrc) {
    [NSException raise:@"Failed to read shaders"
                format:@"%@", [error localizedDescription]];
  }
  self._library = [self._device newLibraryWithSource:librarySrc
                                             options:nil
                                              error:&error];
}

- (void)createRenderPipelineState {
  // Create a render pipeline descriptor
  MTLRenderPipelineDescriptor *pipelineDescriptor =  [[MTLRenderPipelineDescriptor alloc] init];
  pipelineDescriptor.vertexFunction =  [self._library newFunctionWithName:@"vertexShader"];
  pipelineDescriptor.fragmentFunction =  [self._library newFunctionWithName:@"fragmentShader"];

  // Set up render pipeline state
  NSError *error = nil;
  self._pipelineState =  [self._device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                      error:&error];
  if (!self._pipelineState) {
    NSLog(@"Failed to create render pipeline state: %@", error);
  }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size 
{
  // Window is not resizable
  (void)view;
  (void)size;
}

- (void)drawInMTKView:(nonnull MTKView *)view 
{
}

- (void)drawLine:(MFPoint *)vertices view:(nonnull MTKView *)view {
  self._vertexBuffer =
      [self._device newBufferWithBytes:vertices
                               length:sizeof(MFPoint) * 2
                              options:MTLResourceStorageModeShared];

  // Draw the Line
  id<MTLCommandBuffer> commandBuffer = [self._commandQueue commandBuffer];
  id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer  renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];

  [renderEncoder setRenderPipelineState:self._pipelineState];
  [renderEncoder setVertexBuffer:self._vertexBuffer offset:0 atIndex:0];
  [renderEncoder drawPrimitives:MTLPrimitiveTypeLine
                    vertexStart:0
                    vertexCount:2];

  [renderEncoder endEncoding];

  [commandBuffer presentDrawable:view.currentDrawable];
  [commandBuffer commit];
}

- (void)drawTriangle:(MFPoint *)vertices view:(nonnull MTKView *)view {
  // Create a vertex buffer with the triangle vertices
  self._vertexBuffer =  [self._device newBufferWithBytes:vertices
                               length:sizeof(MFPoint) * 3
                              options:MTLResourceStorageModeShared];

  // Draw the triangle
  id<MTLCommandBuffer> commandBuffer = [self._commandQueue commandBuffer];
  id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer  renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];

  [renderEncoder setRenderPipelineState:self._pipelineState];
  [renderEncoder setVertexBuffer:self._vertexBuffer offset:0 atIndex:0];
  [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                    vertexStart:0
                    vertexCount:3];

  [renderEncoder endEncoding];

  [commandBuffer presentDrawable:view.currentDrawable];
  [commandBuffer commit];
}

- (void)drawRectangle:(MFPoint *)vertices
{

}

@end

@implementation M_MView

@end

void M_Renderer_init(M_Renderer *renderer, M_Window *window) 
{
  // Get the Window
  NSWindow *nsWindow = (__bridge NSWindow *)(window->delegate);
  NSRect frame = NSMakeRect(0, 0, 800, 600);
  // initialize the renderer
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  if (device == nil) {
    [NSException raise:@"Failed to create Metal device"
                format:@"Failed to create Metal device"];
  }
  renderer->_view = [[M_MView alloc] initWithFrame:frame device:device];
  if (renderer->_view == nil) {
    [NSException raise:@"Failed to create Metal view"
                format:@"Failed to create Metal view"];
  }
  if (renderer->_view.device == nil) {
    [NSException raise:@"Failed to create Metal device"
                format:@"Failed to create Metal device"];
  }
  renderer->_delegate = [[MTK_Renderer alloc] initWithMetalView:renderer->_view];
  [renderer->_view setDelegate:renderer->_delegate];
  [nsWindow setContentView:renderer->_view];
}

void M_Renderer_destroy(M_Renderer *renderer) {}

void M_Renderer_Clear(M_Renderer *renderer, M_Color color) 
{
  MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
  passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
  passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
  passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
  MFPoint vertices[3] = {
    {100, 100},
    {500, 100},
    {300, 300}
  };
  [renderer->_delegate drawTriangle:vertices view:renderer->_view];
}
