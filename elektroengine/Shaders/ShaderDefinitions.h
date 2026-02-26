
#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h


struct VertexIn {
    float4 position [[attribute(0)]];
    float femValue [[attribute(FEMBuffer)]];

};

struct VertexOut {
    float4 position [[position]];
    float2 worldPos;
    float femValue;
    float worldY;
};

#endif /* ShaderDefinitions_h */
