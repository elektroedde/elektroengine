#ifndef Common_h
#define Common_h
#import <simd/simd.h>

#ifndef __METAL_VERSION__
#import "meshing.hpp"
#endif

struct Params {
    unsigned int width;
    unsigned int height;
    float minY;
    float maxY;
    float minFem;
    float maxFem;
    int colormapChoice;
    bool showContours;
    
    float surfaceMinX;
    float surfaceMaxX;
    float surfaceMinY;
    float surfaceMaxY;
    float surfaceMinZ;
    float surfaceMaxZ;
    unsigned int xmode;
    unsigned int zmode;
};

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

struct VectorInstance{
    vector_float2 position;
    float rotation;
};

enum BufferIndices {
    VertexBuffer = 0,
    UniformsBuffer = 11,
    ParamsBuffer = 12,
    FEMBuffer = 13,
    InstanceBuffer = 14
};

struct Particle {
    vector_float2 position;
    vector_float2 velocity;
    vector_float2 acceleration;
    float direction;
    float speed;
};

#endif /* Common_h */
