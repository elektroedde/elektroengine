#include <metal_stdlib>
using namespace metal;

constant float3 kPlasma[16] = {
    float3(0.050383, 0.029803, 0.527975),
    float3(0.200445, 0.017902, 0.593364),
    float3(0.312543, 0.008239, 0.635700),
    float3(0.417642, 0.000564, 0.658390),
    float3(0.517933, 0.021563, 0.654109),
    float3(0.610667, 0.090204, 0.619951),
    float3(0.692840, 0.165141, 0.564522),
    float3(0.764193, 0.240396, 0.502126),
    float3(0.826588, 0.315714, 0.441316),
    float3(0.881443, 0.392529, 0.383229),
    float3(0.928329, 0.472975, 0.326067),
    float3(0.965024, 0.559118, 0.268513),
    float3(0.988260, 0.652325, 0.211364),
    float3(0.994141, 0.753137, 0.161404),
    float3(0.977995, 0.861432, 0.142808),
    float3(0.940015, 0.975158, 0.131326)
};

float3 plasma(float t) {
    float scaled = t * 15.0;
    int idx = clamp(int(scaled), 0, 14);
    float localT = scaled - float(idx);
    return mix(kPlasma[idx], kPlasma[idx + 1], localT);
}
