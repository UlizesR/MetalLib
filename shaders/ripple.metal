#include <metal_stdlib>
using namespace metal;

struct RippleUniforms {
    float time;
    float frequency;
    float speed;
    float aspect;
};

struct VertexOut {
    float4 position [[position]];
    float2 ndc;
};

vertex VertexOut vertexMain(uint vid [[vertex_id]]) {
    float2 positions[3] = { float2(-1,-1), float2(3,-1), float2(-1,3) };
    VertexOut out;
    out.position = float4(positions[vid], 0.0, 1.0);
    out.ndc = positions[vid];
    return out;
}

fragment float4 fragmentMain(VertexOut in [[stage_in]], constant RippleUniforms& u [[buffer(0)]]) {
    float2 uv = float2(in.ndc.x * u.aspect, in.ndc.y);
    float dist = length(uv);
    float wave = sin(dist * u.frequency - u.time * u.speed);
    float t = wave * 0.5 + 0.5;
    float3 col = mix(float3(0.1, 0.2, 0.4), float3(0.3, 0.6, 1.0), t);
    return float4(col, 1.0);
}
