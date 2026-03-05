

#include <metal_stdlib>
#include <metal_common>
#include "Common.h"
using namespace metal;
#include "ShaderDefinitions.h"



float3 drawGrid2(float2);
float3 turbo2(float);
float3 googleTurbo(float);
float3 viridis(float);
float3 inferno(float);
float3 plasma(float);
float3 cividis(float);
float3 magma(float);
float3 jet(float);
float3 turbo(float);

fragment float4 fragment_background(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {

    float3 color = drawGrid2(in.worldPos);
    return float4(color, 1);
}

fragment float4 fragment_graph(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {

    
    return float4(0.6, 0.1, 0.8, 1);
}

fragment float4 fragment_surface(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {
    
    float normalizedHeight = (in.worldY - params.minY) / (params.maxY - params.minY);
    float3 color = turbo2(normalizedHeight);
    
    return float4(color, 1);
}

fragment float4 fragment_vector(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {

    float3 red = float3(1, 0.3, 0.3);
    float3 blue = float3(0.3, 0.3, 1);
    
    float result = smoothstep(0, params.width, in.position.x);
    float3 color = mix(red, blue, result);
    return float4(color, 1);
}

fragment float4 fragment_fem(constant Params &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]]) {
    
    float t = clamp((in.femValue - params.minFem) / (params.maxFem - params.minFem), 0.0, 1.0);

    float3 color;

    switch(params.colormapChoice) {
        case 0:
            color = googleTurbo(t);
            break;
        case 1:
            color = viridis(t);
            break;
        case 2:
            color = inferno(t);
            break;
        case 3:
            color = plasma(t);
            break;
        case 4:
            color = cividis(t);
            break;
        case 5:
            color = magma(t);
            break;
        case 6:
            color = jet(t);
            break;
        case 7:
            color = turbo(t);
            break;
        default:
            color = float3(1,1,1);
            break;
    }


    return float4(color, 1);

}

