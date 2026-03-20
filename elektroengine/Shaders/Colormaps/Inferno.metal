#include <metal_stdlib>
using namespace metal;

constant float3 kInferno[16] = {
    float3(0.001462, 0.000466, 0.013866),
    float3(0.046915, 0.030324, 0.150164),
    float3(0.142378, 0.046242, 0.308553),
    float3(0.258234, 0.038571, 0.406485),
    float3(0.366529, 0.071579, 0.431994),
    float3(0.472328, 0.110547, 0.428334),
    float3(0.578304, 0.148039, 0.404411),
    float3(0.682656, 0.189501, 0.360757),
    float3(0.780517, 0.243327, 0.299523),
    float3(0.865006, 0.316822, 0.226055),
    float3(0.929644, 0.411479, 0.145367),
    float3(0.970919, 0.522853, 0.058367),
    float3(0.987622, 0.645320, 0.039886),
    float3(0.978806, 0.774545, 0.176037),
    float3(0.950018, 0.903409, 0.380271),
    float3(0.988362, 0.998364, 0.644924)
};

float3 inferno(float t) {
    float scaled = t * 15.0;
    int idx = clamp(int(scaled), 0, 14);
    float localT = scaled - float(idx);
    return mix(kInferno[idx], kInferno[idx + 1], localT);
}
