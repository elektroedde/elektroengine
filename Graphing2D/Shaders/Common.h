//
//  Common.h
//  Graphing2D
//
//  Created by Edvin Berling on 2026-02-24.
//

#ifndef Common_h
#define Common_h
#import <simd/simd.h>
typedef struct {
    unsigned int width;
    unsigned int height;
} Params;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef enum {
    VertexBuffer = 0,
    UniformsBuffer = 11,
    ParamsBuffer = 12
} BufferIndices;
#endif /* Common_h */
