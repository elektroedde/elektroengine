
#include <metal_stdlib>
using namespace metal;
#include "Common.h"
#include "ShaderDefinitions.h"

vertex VertexOut vertex_background(VertexIn in [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    VertexOut out;

    float4 world = uniforms.modelMatrix * in.position;


    out.worldPos = world.xy;

    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * world;

    return out;
}

vertex VertexOut vertex_graph(VertexIn in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    VertexOut out;

    out.position = position;
    return out;
}

vertex VertexOut vertex_vector(VertexIn in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    VertexOut out;

    out.position = position;
    return out;
}

vertex VertexOut vertex_fem(VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    VertexOut out;

    out.position = position;
    out.femValue = in.femValue;

    return out;
}

vertex VertexOut vertex_surface(VertexIn in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    float4 worldPosition = uniforms.modelMatrix * in.position;
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition;
    VertexOut out;

    out.position = position;
    out.worldY = worldPosition.y;
    return out;
}
