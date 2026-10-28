#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec4 uColor1;
uniform vec4 uColor2;
uniform vec4 uColor3;
uniform vec4 uColor4;

out vec4 fragColor;

// Simplex-inspired 2D noise helper
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

    vec2 i = floor(p + (p.x + p.y) * K1);
    vec2 a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x);
    vec2 o = vec2(m, 1.0 - m);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0 * K2;

    vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    vec3 n = h * h * h * h * vec3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));

    return dot(n, vec3(70.0));
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution.xy;

    // Fluid warp coordinates
    float t = uTime * 0.15;
    vec2 warp = vec2(
        noise(uv * 2.0 + vec2(t, 0.0)),
        noise(uv * 2.0 + vec2(0.0, t * 1.2))
    );

    vec2 p = uv + warp * 0.25;

    // Multi-point radial interpolations based on dynamic palette colors
    float d1 = distance(p, vec2(0.2, 0.2) + 0.1 * vec2(sin(t), cos(t)));
    float d2 = distance(p, vec2(0.8, 0.3) + 0.1 * vec2(cos(t * 1.1), sin(t * 0.9)));
    float d3 = distance(p, vec2(0.3, 0.8) + 0.1 * vec2(sin(t * 0.8), -cos(t * 1.3)));
    float d4 = distance(p, vec2(0.7, 0.8) + 0.1 * vec2(-cos(t * 1.2), sin(t * 0.7)));

    float w1 = smoothstep(1.2, 0.0, d1);
    float w2 = smoothstep(1.2, 0.0, d2);
    float w3 = smoothstep(1.2, 0.0, d3);
    float w4 = smoothstep(1.2, 0.0, d4);

    float sum = w1 + w2 + w3 + w4 + 0.0001;
    vec4 finalColor = (uColor1 * w1 + uColor2 * w2 + uColor3 * w3 + uColor4 * w4) / sum;

    // Subtle dark vignette towards screen borders
    float vignette = 1.0 - smoothstep(0.4, 1.4, length(uv - 0.5) * 1.5);
    finalColor.rgb *= clamp(vignette, 0.2, 1.0);

    fragColor = finalColor;
}
