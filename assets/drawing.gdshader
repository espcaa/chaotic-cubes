shader_type canvas_item;

instance uniform vec4 first_replace_color : source_color;
instance uniform vec4 second_replace_color : source_color;
instance uniform vec4 first_replaced_color : source_color;
instance uniform vec4 second_replaced_color : source_color;
instance uniform float tolerance : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (distance(tex_color, first_replace_color) < tolerance) {
        tex_color = first_replaced_color;
    } else if (distance(tex_color, second_replace_color) < tolerance) {
        tex_color = second_replaced_color;
    }

    COLOR = tex_color;
}
