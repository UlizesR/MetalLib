#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float4 position [[ attribute(0) ]];
};

struct RasterizerData{
    float4 position [[ position ]];
    float4 color;
};

struct TransformIn{
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
};

vertex RasterizerData vertexShader(
    const VertexIn vIn [[ stage_in ]], 
    constant TransformIn &trans [[ buffer(1) ]], 
    constant float4 &color [[ buffer(2) ]],
    constant float4x4 &modelMatrix [[ buffer(3) ]]
)
{
    RasterizerData rd;
    
    rd.position = trans.viewMatrix * trans.projectionMatrix * modelMatrix * vIn.position;
    rd.color = color;
    
    return rd;
}

fragment half4 fragmentShader(RasterizerData rd [[ stage_in ]]) 
{
    float4 color = rd.color;
                                                        
    return half4(color.r, color.g, color.b, color.a);
}