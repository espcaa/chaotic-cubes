shader_type canvas_item;

instance uniform vec4 replace_color_to_primary : source_color;
instance uniform vec4 replace_color_to_secondary : source_color;
instance uniform vec4 replace_color_to_accent : source_color;
instance uniform vec4 replace_color_to_background : source_color;
instance uniform vec4 primary_replaced_color : source_color;
instance uniform vec4 secondary_replaced_color : source_color;
instance uniform vec4 accent_replaced_color : source_color;
instance uniform vec4 background_replaced_color : source_color;
instance uniform float tolerance : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (distance(tex_color, replace_color_to_primary) < tolerance) {
        tex_color = primary_replaced_color;
    } else if (distance(tex_color, replace_color_to_secondary) < tolerance) {
        tex_color = secondary_replaced_color;
    } else if (distance(tex_color, replace_color_to_accent) < tolerance) {
        tex_color = accent_replaced_color;
    } else if (distance(tex_color, replace_color_to_background) < tolerance) {
        tex_color = background_replaced_color;
    }

    COLOR = tex_color;
}
