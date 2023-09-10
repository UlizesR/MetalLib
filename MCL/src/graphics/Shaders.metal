#include <metal_stdlib>
using namespace metal;

#include "MCL/def.h"

struct Fragment 
{
    float4 position [[position]];
    float4 color;
};

vertex Fragment vertexShader(const device Vertex *vertexArray[[buffer(0)]], unsigned int vid_id [[vertex_id]])
{
    Vertex input = vertexArray[vid_id];

    Fragment output;
    output.position = float4(input.position.x, input.position.y, 0, 1.0);
    output.color = input.color;

    return output;
}

fragment float4 fragmentShader(const Fragment input [[stage_in]])
{
    return input.color;
}