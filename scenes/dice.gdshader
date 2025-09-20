shader_type canvas_item;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);

    vec3 pastel_modulator = vec3(
        0.5 + 0.5 * sin(TIME * 2.0 + UV.x * 3.0),
        0.5 + 0.5 * cos(TIME * 2.5 + UV.y * 3.0 + 1.0),
        0.5 + 0.5 * sin(TIME * 3.0 + (UV.x + UV.y) * 3.0 + 2.0)
    );

    float pixel_noise = fract(sin(dot(UV.xy * 100.0, vec2(12.9898,78.233))) * 43758.5453) * 0.03;
    pastel_modulator += pixel_noise;

    float mix_amount = 0.35;
    vec3 final_rgb = mix(base_color.rgb, pastel_modulator, mix_amount);
    final_rgb = pow(final_rgb, vec3(0.9));

    COLOR = vec4(final_rgb, base_color.a);
}
