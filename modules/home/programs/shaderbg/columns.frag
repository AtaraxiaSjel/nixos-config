// Author: Thomas Stehle
// Title: Beving (2021)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
//
// After the video for Joep Beving's "Sinfonia (After Bach,
// BWV 248)": https://youtu.be/mJa6QbJfvHk
//
// Try the shader in fullscreen mode. Would make a nice screen
// saver.

const float PI = 3.14159;

const vec3 COLOR_BG = vec3( 17,  26,  46) / 255.0;
const vec3 COLOR_FG = vec3(121, 133, 156) / 255.0;

// https://www.shadertoy.com/view/4djSRW
float hash(in float p) {
    p = fract(p * 0.011);
    p *= p + 7.5;
    p *= p + p;
    return fract(p);
}

// https://www.shadertoy.com/view/4djSRW
float hash(in vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.13);
    p3 += dot(p3, p3.yzx + 3.333);
    return fract((p3.x + p3.y) * p3.z);
}

float hash(in vec3 p) {
    vec3 q = fract(p * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

// https://www.shadertoy.com/view/4dS3Wd
float vnoise(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Four corners in 2D of a tile
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    // Smooth interpolation (smoothstep without clamping)
    vec2 u = f*f * (3.0 - 2.0*f);

    // Mix 4 corners
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// https://github.com/patriciogonzalezvivo/lygia
vec3 brightness_contrast(in vec3 color, in float brightness, in float contrast ) {
    return (color - 0.5) * contrast + 0.5 + brightness;
}

float stripes(in vec2 p, in float nstripes) {
    // Stripe config
    vec2 sc = vec2(nstripes, 1.0) * p;
    vec2 id = floor(sc);
    vec2 cc = fract(sc);
    
    // Random variables
    float r1 = hash(id.x);
    float r2 = hash(id.x * 13.37);
    float r3 = hash(id.x * 47.11);
    float r4 = hash(id.x * 73.23);
    
    // Horizontal variation
    float freq = nstripes * PI;
    float f = smoothstep(1.0, 0.0, sin(freq * p.x));
    
    // Vertical variation
    float t = sin(0.25 * iTime + 10.0 * r1);   // Randomized time offset
    float dt = cos(0.25 * iTime + 10.0 * r1);  // Derivative of time offset
    float len = 0.9 * r2;                      // Randomized length
    float slt = -0.01 + 0.02 * r3;             // Randomized slant
    float ext = 0.2 * t * r4;                  // Randomized extent
    f *= step(len + slt * cc.x - ext, cc.y);
    
    // Fade out when receeding
    f *= smoothstep(-0.1, 0.5, dt);
    
    // Apply noise
    f *= 0.5 + 0.5 * vnoise(10.0 * (cc + 0.2 * t));

    return f;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Normalize input coordinates
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // Background
    vec3 col = mix(COLOR_BG, brightness_contrast(COLOR_FG, -0.3, 1.25), 1.0 - length(uv - vec2(0.5, 1.0)));
    
    // Stripe layers
    col = mix(col, COLOR_FG, stripes(uv, 200.0));
    col = mix(col, brightness_contrast(COLOR_FG, -0.1, 1.0), stripes(uv + vec2(0.123, 0.0), 250.0));
    col = mix(col, brightness_contrast(COLOR_FG, -0.2, 1.0), stripes(uv + vec2(0.456, 0.0), 150.0));
    col = mix(col, brightness_contrast(COLOR_FG, -0.3, 1.0), stripes(uv + vec2(0.789, 0.0), 300.0));
    
    // Add layer of animated white noise
    col += 0.1 * vec3(hash(vec3(fragCoord.xy, fract(0.001 * iTime))));
    
    // Vignetting
    float vig = length(uv - vec2(0.5)) * 0.85;
    vig = vig * vig + 1.0;
    col *= 1.0 / (vig * vig);
    
    // Final result
    fragColor = vec4(col, 1.0);
}
