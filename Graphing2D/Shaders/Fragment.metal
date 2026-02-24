//
//  Shaders.metal
//  Graphing2D
//
//  Created by Edvin Berling on 2026-02-24.
//

#include <metal_stdlib>
#include <metal_common>
#include "Common.h"
using namespace metal;
#include "ShaderDefinitions.h"



float3 drawGrid2(float2);


fragment float4 fragment_background(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {

    float3 color = drawGrid2(in.worldPos);
    return float4(color, 1);
}

fragment float4 fragment_graph(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {


    return float4(0.34, 0, 0.55, 1);
}

fragment float4 fragment_vector(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {

    float3 red = float3(1, 0.3, 0.3);
    float3 blue = float3(0.3, 0.3, 1);
    
    float result = smoothstep(0, params.width, in.position.x);
    float3 color = mix(red, blue, result);
    return float4(color, 1);
}



