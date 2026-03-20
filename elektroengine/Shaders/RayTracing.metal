#include <metal_stdlib>
#include "Common.h"

using namespace metal;

struct Ray {
    float3 origin;
    float3 direction;
};

struct Sphere {
    float3 center;
    float radius;
};

struct Light {
    float3 position;
};

constant Sphere sphere = Sphere{float3(0.0, 2.5, 0.0), 5.0};

float distanceToSphere(Ray ray, Sphere sphere) {
    return length(ray.origin - sphere.center) - sphere.radius;
}

float distanceToScene(Ray ray) {
    float d2s1 = distanceToSphere(ray, sphere);
    return d2s1;
}
float3 getNormal(float3 hitPosition, Sphere sphere) {
    return normalize(hitPosition - sphere.center);
}

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    constant float &time [[buffer(0)]],
                    uint2 pixel [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();
    float aspect = float(width) / float(height);

    float2 uv = float2(pixel) / float2(width, height);
    uv = uv * 2.0 - 1.0;
    uv.x *= aspect;
    float4 color = float4(0.9, 0.9, 0.8, 1.0);

    color = 0;
    uv.y = -uv.y;
    
    Ray ray = Ray{float3(0.0, 4.0, -12.0), normalize(float3(uv, 1.0))};
    
    for(int i = 0; i < 300; i++) {
        float dist = distanceToScene(ray);
        
        if(dist < 0.01) {
            color = float4(1.0, 0.2, 1.0, 1.0);
            break;
        }
        
        ray.origin += ray.direction * dist;
    }
    
    float3 n = getNormal(ray.origin, sphere);
    
    Light light = Light{float3(sin(time) * 10.0, 5.0, cos(time)*10.0)};
    light.position = normalize(light.position);
    float l = dot(n, light.position);
    color = float4(color.xyz*l, 1.0);
    
    output.write(color, pixel);
}
