
#include <metal_stdlib>
using namespace metal;


float3 drawGrid(float x, float y, int width, int height) {
    if(int(x) == width/2 || int(y) == height/2) {
        return float3(1, 1, 1);
    }
    //if(int(x) % 100 == 0 || int(y) % 100 == 0) {
    //    return float3(0.5,0.5,0.5);
    //}
    return float3(0,0,0);
}

float gridLine(float coord, float scale)
{
    float v = coord / scale;

    float dist = abs(fract(v - 0.5) - 0.5);

    float width = fwidth(v);     // pixel footprint

    return 1.0 - smoothstep(0.0, width, dist);
}

float line(float coord, float scale, float thicknessMultiplier)
{
    float v = coord / scale;

    float dist = abs(fract(v - 0.5) - 0.5);

    float width = fwidth(v) * thicknessMultiplier;

    return 1.0 - smoothstep(0.0, width, dist);
}

float axisLine(float coord, float thicknessMultiplier)
{
    float width = fwidth(coord) * thicknessMultiplier;
    float dist = abs(coord);

    return 1.0 - smoothstep(0.0, width, dist);
}

float3 drawGrid2(float2 worldPos)
{
    float minorScale = 1.0;
    float majorScale = 10.0;

    // Minor grid
    float minorX = line(worldPos.x, minorScale, 1.0);
    float minorY = line(worldPos.y, minorScale, 1.0);
    float minor = max(minorX, minorY);

    // Major grid
    float majorX = line(worldPos.x, majorScale, 1.5);
    float majorY = line(worldPos.y, majorScale, 1.5);
    float major = max(majorX, majorY);

    // Axis (thicker)
    float axisX = axisLine(worldPos.x, 3.0);
    float axisY = axisLine(worldPos.y, 3.0);
    float axis = max(axisX, axisY);

    float3 color = float3(0.15) * minor;
    color = mix(color, float3(0.35), major);
    color = mix(color, float3(1.0), axis);

    return color;
}

float3 turbo2(float x)
{
    x = clamp(x, 0.0, 1.0);

    const float4 kRedVec4   = float4(0.13572138, 4.61539260, -42.66032258, 132.13108234);
    
    const float4 kGreenVec4 = float4(0.09140261, 2.19418839,  4.84296658,  -14.18503333);
    const float4 kBlueVec4  = float4(0.10667330, 12.64194608, -60.58204836, 110.36276771);

    const float2 kRedVec2   = float2(-152.94239396, 59.28637943);
    const float2 kGreenVec2 = float2( 4.27729857,   2.82956604);
    const float2 kBlueVec2  = float2(-89.90310912, 27.34824973);

    float4 v4 = float4(1.0, x, x*x, x*x*x);
    float2 v2 = float2(x*x*x*x, x*x*x*x*x);

    return float3(
        dot(v4, kRedVec4)   + dot(v2, kRedVec2),
        dot(v4, kGreenVec4) + dot(v2, kGreenVec2),
        dot(v4, kBlueVec4)  + dot(v2, kBlueVec2)
    );
}
