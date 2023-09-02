#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertexShader(const device VertexIn *vertices [[buffer(0)]],
                              const constant float4 &color [[buffer(1)]],
                              uint vid [[vertex_id]])
{
    VertexOut out;
    out.position = float4(vertices[vid].position, 0.0, 1.0);
    out.color = color;
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]])
{
    return interpolated.color;
}