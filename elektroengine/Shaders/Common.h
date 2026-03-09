#ifndef Common_h
#define Common_h
#import <simd/simd.h>

#ifndef __METAL_VERSION__
#import "meshing.hpp"
#endif

typedef struct {
    unsigned int width;
    unsigned int height;
    float minY;
    float maxY;
    float minFem;
    float maxFem;
    int colormapChoice;
    bool showContours;
} Params;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef enum {
    VertexBuffer = 0,
    UniformsBuffer = 11,
    ParamsBuffer = 12,
    FEMBuffer = 13
} BufferIndices;

#endif /* Common_h */
