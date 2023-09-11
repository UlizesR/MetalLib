#import "MCL/graphics/shapes.h"
#include "MCL/graphics/renderer.h"

#import <simd/simd.h>
#import <Cocoa/Cocoa.h>

@implementation MCL_NsTriangle

- (id)init:(id<MTLDevice>)device points:(MCL_FPoint *)points color:(MCL_Color)color
{
    self = [super init];
    if (!self)
    {
        fprintf(stderr, "Failed to create MCL_NsTriangle\n");
        return nil;
    }
    Vertex vertices[] =
    {
        {MCL_FPOINT2VECTOR_F2(points[0]), MCL_COLOR2VECTOR_F4(color)},
        {MCL_FPOINT2VECTOR_F2(points[1]), MCL_COLOR2VECTOR_F4(color)},
        {MCL_FPOINT2VECTOR_F2(points[2]), MCL_COLOR2VECTOR_F4(color)}
    };
    self.vertexBuffer = [device newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
    return self;
}
@end

void MCL_DrawTriangle(MCL_Renderer *renderer, MCL_Triangle *triangle, MCL_FPoint *points, MCL_Color color)
{
    // check if renderer null
    if (renderer == NULL) {
        fprintf(stderr, "Failed to draw triangle: renderer is null\n");
        return;
    }
    // get the mtk_render 
    MTK_Renderer *mtk_renderer = (__bridge MTK_Renderer *)(renderer->_this);
    // get the device
    id<MTLDevice> device = renderer->device->_device.device;
    MCL_NsTriangle *ns_triangle = [[MCL_NsTriangle alloc] init:device points:points color:color];
    if (!ns_triangle)
    {
        fprintf(stderr, "Failed to draw triangle: failed to create MCL_NsTriangle\n");
        return;
    }
    mtk_renderer.mesh = ns_triangle;
    mtk_renderer.vertexBuffer = ns_triangle.vertexBuffer;

    triangle->p1 = points[0];
    triangle->p2 = points[1];
    triangle->p3 = points[2];
    triangle->color = color;
    triangle->_this = (__bridge void *)(ns_triangle);
}