//
//  ShaderDefinitions.h
//  Graphing2D
//
//  Created by Edvin Berling on 2026-02-25.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h


struct VertexIn {
    float4 position [[attribute(0)]];

};

struct VertexOut {
    float4 position [[position]];
    float2 worldPos;
};

#endif /* ShaderDefinitions_h */
