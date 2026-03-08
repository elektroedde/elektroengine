#include <metal_stdlib>
using namespace metal;

constant float3 kCividis[16] = {
    float3(0.000000, 0.135112, 0.304751),
    float3(0.000000, 0.181610, 0.421859),
    float3(0.117612, 0.225935, 0.434308),
    float3(0.208926, 0.272546, 0.424809),
    float3(0.279411, 0.318677, 0.423031),
    float3(0.342246, 0.364939, 0.428559),
    float3(0.401418, 0.411790, 0.440708),
    float3(0.458366, 0.459552, 0.460457),
    float3(0.517920, 0.508454, 0.472707),
    float3(0.582087, 0.558670, 0.468118),
    float3(0.648222, 0.610553, 0.454801),
    float3(0.716177, 0.664384, 0.432386),
    float3(0.785965, 0.720438, 0.399613),
    float3(0.857809, 0.778969, 0.353259),
    float3(0.932180, 0.840159, 0.285880),
    float3(0.995737, 0.909344, 0.217772)
};

float3 cividis(float t) {
    float scaled = t * 15.0;
    int idx = clamp(int(scaled), 0, 14);
    float localT = scaled - float(idx);
    return mix(kCividis[idx], kCividis[idx + 1], localT);
}
