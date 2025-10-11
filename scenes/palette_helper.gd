extends Node

@export var seed_color: Color

var palette = {}


func generate_palette(seed: Color) -> Dictionary:
	var palette: Dictionary = {}

	var h = seed.h

	# Primary: pastel
	var s_primary = clamp(seed.s, 0.3, 0.5)  # lower saturation for pastel
	var v_primary = clamp(seed.v * 2, 0.7, 1.0)  # bright
	palette["primary"] = Color.from_hsv(h, s_primary, v_primary)

	# Background: dark, saturated
	var s_bg = clamp(seed.s * 1.0, 0.6, 1.0)
	var v_bg = clamp(seed.v * 0.1, 0.05, 0.15)
	palette["background"] = Color.from_hsv(h, s_bg, v_bg)

	# Secondary: like background but lighter
	var s_secondary = s_bg
	var v_secondary = clamp(v_bg * 1.5, 0, 0.3)
	palette["secondary"] = Color.from_hsv(h, s_secondary, v_secondary)

	# Accent: pops
	var accent_h = fmod(h + 0.02, 1.0)  # slightly shifted hue
	var accent_s = clamp(seed.s * 1.0, 0.5, 1.0)
	var accent_v = clamp(seed.v * 1.0, 0.7, 1.0)
	palette["accent"] = Color.from_hsv(accent_h, accent_s, accent_v)

	var tertiary_s = clamp(seed.s * 1.1, 0.4, 0.8)
	var tertiary_v = clamp(seed.v * 1.3, 0.5, 0.9)
	palette["tertiary"] = Color.from_hsv(h, tertiary_s, tertiary_v)

	# add a reversed hue color for contrast and error states

	var error_h = fmod(h + 0.5, 1.0)  # opposite hue
	var error_s = clamp(seed.s * 1.0, 0.5, 0.7)
	var error_v = clamp(seed.v * 1.0, 0.9, 1.0)
	palette["error"] = Color.from_hsv(error_h, error_s, error_v)

	return palette


func assign_new_palette():
	palette = generate_palette(seed_color)


func get_palette():
	return palette


func get_color(color_name: String) -> Color:
	if palette.has(color_name):
		return palette[color_name]
	else:
		return Color.BLACK


func change_base_color(color: Color):
	seed_color = color
	assign_new_palette()
