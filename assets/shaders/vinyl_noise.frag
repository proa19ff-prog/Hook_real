#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;

out vec4 fragColor;

float pseudoRandom(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution.xy;
    
    // Dynamic grain modulated by time
    float grain = pseudoRandom(uv + fract(uTime * 17.31));
    float centeredGrain = (grain - 0.5) * 2.0;

    // Output transparent overlay with noise in alpha/rgb
    fragColor = vec4(vec3(centeredGrain > 0.0 ? 1.0 : 0.0), abs(centeredGrain) * uIntensity);
}
