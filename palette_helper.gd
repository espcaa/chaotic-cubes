extends Node

@export var seed_color: Color

var palette = {}

func generate_palette(seed: Color) -> Dictionary:
	var palette: Dictionary = {}
	
	var h = seed.h

	var s = clamp(seed.s, 0.4, 0.7)
	var v = clamp(seed.v, 0.6, 0.9)

	palette["secondary"] = Color.from_hsv(h, s, v)

	var s_light = clamp(s - 0.15, 0, 1)
	var v_light = clamp(v + 0.15, 0, 1)
	palette["primary"] = Color.from_hsv(h, s_light, v_light)
	
	var bg_s = clamp(s * 0.5, 0, 1)
	var bg_v = clamp(v * 0.15, 0, 1)
	palette["background"] = Color.from_hsv(h, bg_s, bg_v)

	var accent_h = fmod(h + 0.05, 1.0)
	var accent_s = clamp(s * 1.1, 0, 1)
	var accent_v = clamp(v * 1.05, 0, 1)
	palette["accent"] = Color.from_hsv(accent_h, accent_s, accent_v)
	
	return palette

func assign_new_palette():
	palette = generate_palette(seed_color)

func get_palette():
	return palette

func get_color(color_name: String) -> Color:
	if palette.has(color_name):
		return palette[color_name]
	else:
		push_warning("Color name '" + color_name + "' not found in palette.")
		return Color.BLACK
