#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

// Simplex-style noise helper
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,
                        0.366025403784439,
                       -0.577350269189626,
                        0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

void main() {
    vec2 st = FlutterFragCoord().xy / u_resolution.xy;
    st.y = 1.0 - st.y; // Match standard screen space
    float t = u_time * 0.35;

    // Organic liquid silk domain warping
    vec2 q = vec2(0.0);
    q.x = snoise(st * 2.2 + vec2(t * 0.2, t * 0.15));
    q.y = snoise(st * 2.2 + vec2(t * 0.1, -t * 0.25));

    vec2 r = vec2(0.0);
    r.x = snoise(st * 3.0 + 1.2 * q + vec2(1.7, 9.2) + 0.15 * t);
    r.y = snoise(st * 3.0 + 1.2 * q + vec2(8.3, 2.8) + 0.18 * t);

    float f = snoise(st * 1.8 + r * 1.4 + vec2(0.0, t * 0.1));
    float n = clamp(f * 0.5 + 0.5, 0.0, 1.0);

    vec3 colBase = vec3(1.0, 0.975, 0.965);
    vec3 colBlush = vec3(0.992, 0.935, 0.953);
    vec3 colRose = vec3(0.95, 0.85, 0.898);
    vec3 colMauveGlow = vec3(0.85, 0.62, 0.74);
    vec3 colDeepWine = vec3(0.557, 0.251, 0.435);

    // Rich gradient interpolation along warped fluid lines
    vec3 color = mix(colBase, colBlush, smoothstep(0.1, 0.5, n));
    color = mix(color, colRose, smoothstep(0.4, 0.75, length(q)));
    color = mix(color, colMauveGlow, smoothstep(0.55, 0.9, length(r)));

    // Subtle luminous ribbons / caustic silk gleam
    float ribbon = sin((st.x * 2.0 + st.y * 3.0 + f * 2.5) * 3.14159 + t * 0.8);
    ribbon = smoothstep(0.7, 0.98, ribbon) * 0.22;
    color = mix(color, colDeepWine, ribbon * 0.45);

    // Soft shimmering gold/champagne pearl highlights
    float sparkle = pow(max(0.0, snoise(st * 8.0 - t * 0.4)), 3.5) * 0.35;
    color += vec3(1.0, 0.95, 0.88) * sparkle;

    // Gentle vignette to keep edges soft and focus on cards
    float vignette = length(st - vec2(0.5, 0.45));
    color = mix(color, colBlush, smoothstep(0.35, 0.95, vignette) * 0.3);

    fragColor = vec4(color, 1.0);
}
