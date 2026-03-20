#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

struct VertexIn {
    float4 position [[attribute(0)]];
    float femValue [[attribute(FEMBuffer)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPos;
    float femValue;
};

#endif /* ShaderDefinitions_h */
