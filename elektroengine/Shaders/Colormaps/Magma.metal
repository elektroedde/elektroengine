#include <metal_stdlib>
using namespace metal;

constant float3 kMagma[16] = {
    float3(0.001462, 0.000466, 0.013866),
    float3(0.043830, 0.033830, 0.141886),
    float3(0.123833, 0.067295, 0.295879),
    float3(0.232077, 0.059889, 0.437695),
    float3(0.341482, 0.080564, 0.492631),
    float3(0.445163, 0.122724, 0.506901),
    float3(0.550287, 0.161158, 0.505719),
    float3(0.658483, 0.196027, 0.490253),
    float3(0.767398, 0.233705, 0.457755),
    float3(0.868793, 0.287728, 0.409303),
    float3(0.944006, 0.377643, 0.365136),
    float3(0.981000, 0.498428, 0.369734),
    float3(0.994738, 0.624350, 0.427397),
    float3(0.997228, 0.747981, 0.516859),
    float3(0.993170, 0.870024, 0.626189),
    float3(0.987053, 0.991438, 0.749504)
};

float3 magma(float t) {
    float scaled = t * 15.0;
    int idx = clamp(int(scaled), 0, 14);
    float localT = scaled - float(idx);
    return mix(kMagma[idx], kMagma[idx + 1], localT);
}
