shader_type canvas_item;

// --- Shader Parameters ---
// You can adjust these uniforms directly in the Godot Inspector.
uniform float pixel_scale : hint_range(0.01, 1.0, 0.01) = 0.5;
uniform float scanline_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float aberration_strength : hint_range(0.0, 0.01, 0.0001) = 0.005;

// The core fragment shader logic.
void fragment() {
    // 1. Pixelation Effect
    // This snaps the texture coordinates (UV) to a grid, simulating a low-res image.
    vec2 uv = floor(UV / pixel_scale) * pixel_scale;

    // 2. Chromatic Aberration (Color Fringing)
    // We sample the screen texture multiple times with slight offsets for RGB.
    // TEXTURE is Godot's built-in uniform for the main screen texture.
    vec2 r_uv = uv + vec2(aberration_strength, 0.0);
    vec2 g_uv = uv; // Green channel is central
    vec2 b_uv = uv - vec2(aberration_strength, 0.0);
    
    vec3 pixel_color = vec3(
        texture(TEXTURE, r_uv).r,
        texture(TEXTURE, g_uv).g,
        texture(TEXTURE, b_uv).b
    );

    // 3. Scanlines
    // We use the fragment's screen position (FRAGCOORD) to create a repeating scanline pattern.
    float scanline = 1.0 - mod(FRAGCOORD.y * 1.0, 2.0) * scanline_strength;
    pixel_color *= scanline;

    // 4. Gamma Correction (for a more accurate look)
    // This makes the colors appear more accurate on a modern screen.
    pixel_color = pow(pixel_color, vec3(2.2));

    // 5. Vignette (Darkens the corners)
    vec2 center = UV - 0.5;
    float vignette = 1.0 - dot(center, center) * 0.5;
    pixel_color *= vignette;

    // Final output color.
    COLOR = vec4(pixel_color, 1.0);
}