#include <metal_stdlib>
#include "Common.h"

using namespace metal;

constant float magfieldHalfH = 5e-2;
constant float magfieldHalfW = 2e-2;

constant float tMin =  0.0;
constant float tMax =  1.0;
constant float yMin =  0.0;
constant float yMax =  2.0;

constant float gravityHalfH = 2*6378e3;
constant float earthRadius = 6378e3;

kernel void clearScreen(texture2d<half, access::read_write> output [[texture(0)]],
                        uint2 id [[thread_position_in_grid]]) {
    int w = output.get_width();
    int h = output.get_height();

    float dsx = float(id.x) / float(w) - 0.5;
    float wireThickPx = 0.004;

    if (abs(dsx) < wireThickPx) {
        output.write(half4(1.0, 1.0, 1.0, 1.0), id);
    } else {
        half4 existing = output.read(id);
        output.write(existing * 1, id);
    }
}

float dydt(float t, float y) {
    return t * y + t * t * t;
}

uint2 mathToPixel(float2 pos, int w, int h) {
    float px = (pos.x - tMin) / (tMax - tMin) * float(w);
    float py = (1.0 - (pos.y - yMin) / (yMax - yMin)) * float(h);
    return uint2(clamp(px, 0.0, float(w - 1)),
                 clamp(py, 0.0, float(h - 1)));
}

// Old, remove ?
kernel void particles(texture2d<half, access::write> output [[texture(0)]],
                      device Particle *particles [[buffer(0)]],
                      uint id [[thread_position_in_grid]]) {
    
    int w = output.get_width();
    int h = output.get_height();
    if(id == 0) {
        float t = particles[id].position.x;
        float y = particles[id].position.y;
        
        float dt = 0.1;
        float slope = dydt(t, y);
        particles[id].position.x += dt;
        particles[id].position.y += slope * dt;
        
        uint2 pixel = mathToPixel(particles[id].position, w, h);
        
        half4 color = half4(1.0);
        output.write(color, pixel);
        output.write(color, pixel + uint2(0, 1));
        output.write(color, pixel - uint2(0, 1));
        output.write(color, pixel + uint2(1, 0));
        output.write(color, pixel - uint2(1, 0));
    } else {
        float t = particles[id].position.x;
        float y = particles[id].position.y;
        
        float dt = 0.1;
        float slope = dydt(t, y) + dydt(t + dt, y + dt*dydt(t, y));
        particles[id].position.x += dt;
        particles[id].position.y += slope * dt/2;
        
        uint2 pixel = mathToPixel(particles[id].position, w, h);
        
        half4 color = half4(1.0, 0.0, 0.0, 1.0);
        output.write(color, pixel);
        output.write(color, pixel + uint2(0, 1));
        output.write(color, pixel - uint2(0, 1));
        output.write(color, pixel + uint2(1, 0));
        output.write(color, pixel - uint2(1, 0));
    }
    
}

uint2 gravityToPixel(float2 pos, int w, int h) {
    float aspect = float(w) / float(h);
    float gravHalfW = gravityHalfH * aspect;
    float px = (pos.x / gravHalfW * 0.5 + 0.5) * float(w);
    float py = (0.5 - pos.y / gravityHalfH * 0.5) * float(h);
    return uint2(clamp(px, 0.0, float(w - 1)),
                 clamp(py, 0.0, float(h - 1)));
}

kernel void gravity(texture2d<half, access::write> output [[texture(0)]],
                    device Particle *particles [[buffer(0)]],
                    constant float &dt [[buffer(1)]],
                    uint id [[thread_position_in_grid]]) {
    
    float m = 5.9722e24;
    float G = 6.6743015e-11;
    
    int w = output.get_width();
    int h = output.get_height();
    
    float r = length(particles[id].position);
    float mag = G*m/(r*r);
    
    float dir = atan2(particles[id].position.y, particles[id].position.x);
    
    particles[id].acceleration = float2(-cos(dir)*mag, -sin(dir)*mag);
    particles[id].velocity += particles[id].acceleration * dt*90/2;
    particles[id].position += particles[id].velocity * dt*90/2;
    
    uint2 pixel = gravityToPixel(particles[id].position, w, h);
    
    half4 color = 1.0;
    output.write(color, pixel);
    output.write(color, pixel + uint2(0, 1));
    output.write(color, pixel - uint2(0, 1));
    output.write(color, pixel + uint2(1, 0));
    output.write(color, pixel - uint2(1, 0));

}

uint2 magfieldToPixel(float2 pos, int w, int h) {
    float px = (pos.x / magfieldHalfW * 0.5 + 0.5) * float(w);
    float py = (0.5 - pos.y / magfieldHalfH * 0.5) * float(h);
    return uint2(clamp(px, 0.0, float(w - 1)),
                 clamp(py, 0.0, float(h - 1)));
}

kernel void magneticfield(texture2d<half, access::read_write> output [[texture(0)]],
                    device Particle *particles [[buffer(0)]],
                    constant float &dt [[buffer(1)]],
                    uint id [[thread_position_in_grid]]) {
    int w = output.get_width();
    int h = output.get_height();
    
    float I0 = 30;
    float mu0 = 4 * M_PI_F * 1e-7;
    float q = 1.602e-19;
    float me = 9.11e-31;
    
    float magneticFieldZ = I0 * mu0 / (2 * M_PI_F * particles[id].position.x);
    
    float3 acc = cross(float3(particles[id].velocity.x, particles[id].velocity.y, 0), float3(0, 0, magneticFieldZ));
    
    particles[id].acceleration = q*acc.xy/me;
    particles[id].velocity += particles[id].acceleration * dt/100000000;
    particles[id].position += particles[id].velocity * dt/100000000;
    
    uint2 pixel = magfieldToPixel(particles[id].position, w, h);
    
    half4 color = 1.0;
    output.write(color, pixel);
    output.write(color, pixel + uint2(0, 1));
    output.write(color, pixel - uint2(0, 1));
    output.write(color, pixel + uint2(1, 0));
    output.write(color, pixel - uint2(1, 0));

}
