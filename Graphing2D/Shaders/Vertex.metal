//
//  Vertex.metal
//  Graphing2D
//
//  Created by Edvin Berling on 2026-02-25.
//

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
