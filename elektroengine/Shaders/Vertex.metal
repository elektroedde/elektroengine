#include <metal_stdlib>
#include "Common.h"
#include "ShaderDefinitions.h"
using namespace metal;

vertex VertexOut vertex_background(VertexIn in [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    float4 world = uniforms.modelMatrix * in.position;

    VertexOut out;
    out.worldPos = world.xyz;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * world;

    return out;
}

vertex VertexOut vertex_colorbar(VertexIn in [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(UniformsBuffer)]]) {
    VertexOut out;
    out.position = in.position;
    out.worldPos = in.position.xyz;
    
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
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                              const device VectorInstance *instances [[buffer(InstanceBuffer)]],
                              uint instanceID [[instance_id]]) {
    VectorInstance inst = instances[instanceID];

    // 2D rotation matrix
    float c = cos(inst.rotation);
    float s = sin(inst.rotation);
    float2 rotated = float2(c * in.position.x - s * in.position.y,
                            s * in.position.x + c * in.position.y);

    // Translate to instance position
    float4 worldPos = float4(rotated.x + inst.position.x,
                             rotated.y + inst.position.y,
                             in.position.z, 1.0);

    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * worldPos;

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
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                                constant Params &params [[buffer(ParamsBuffer)]],
                                constant float &timer [[buffer(20)]]) {
    float Lx = params.surfaceMaxX - params.surfaceMinX;
    float Lz = params.surfaceMaxZ - params.surfaceMinZ;
    in.position.y = sin((in.position.x - params.surfaceMinX) * 3.14159 * params.xmode / Lx)
                  * sin((in.position.z - params.surfaceMinZ) * 3.14159 * params.zmode / Lz)
                  * sin(3*timer);
    float4 worldPosition = uniforms.modelMatrix * in.position;
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition;
    
    VertexOut out;
    out.position = position;
    out.worldPos = worldPosition.xyz;

    return out;
}

vertex VertexOut vertex_gravity(VertexIn in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                                constant Params &params [[buffer(ParamsBuffer)]],
                                constant float &timer [[buffer(20)]]) {
    
    
    float r = length(in.position.xz);
    
    float Rs = 10.0;
    float height;
    if (r >= Rs) {
        height = 2.0 * sqrt(Rs * (r - Rs));
    } else {
        // Continue the funnel downward inside the Schwarzschild radius
        height = -2.0 * sqrt(Rs * (Rs - r));
    }
    in.position.y = height;
    float4 worldPosition = uniforms.modelMatrix * in.position;
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition;
    
    VertexOut out;
    out.position = position;
    out.worldPos = worldPosition.xyz;

    return out;
}
vertex VertexOut vertex_particles() {
    VertexOut out;
    return out;
}
