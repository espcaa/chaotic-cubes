extends Button

enum ColorRole { CUSTOM, PRIMARY, ACCENT, BACKGROUND, SECONDARY }

@export var bg_color: ColorRole = ColorRole.PRIMARY
@export var text_color: ColorRole = ColorRole.SECONDARY

# Optional custom colors
@export var custom_bg_color: Color = Color.TRANSPARENT
@export var custom_text_color: Color = Color.WHITE

# Hover + pressed background colors
@export var hover_color: Color = Color(0.9, 0.9, 0.9)
@export var pressed_color: Color = Color(0.7, 0.7, 0.7)

@export var font_size: int = 16
@export var label_text: String = "Label"

var cached_bg: Color = Color.TRANSPARENT
var cached_font: Color = Color.TRANSPARENT


func _ready() -> void:
	text = label_text
	add_theme_font_size_override("font_size", font_size)
	_update_styles()


func _process(_delta: float) -> void:
	var bg_color_real = get_palette_color(bg_color, custom_bg_color)
	var font_color_real = get_palette_color(text_color, custom_text_color)

	if cached_bg != bg_color_real or cached_font != font_color_real:
		_update_styles()


func _update_styles() -> void:
	var bg_color_real = get_palette_color(bg_color, custom_bg_color)
	var font_color_real = get_palette_color(text_color, custom_text_color)

	cached_bg = bg_color_real
	cached_font = font_color_real

	# Font color
	add_theme_color_override("font_color", font_color_real)

	# Normal
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = bg_color_real
	style_normal.set_border_width_all(2)
	style_normal.border_color = font_color_real
	style_normal.set_corner_radius_all(8)
	style_normal.content_margin_left = 10
	style_normal.content_margin_right = 10
	style_normal.content_margin_top = 10
	style_normal.content_margin_bottom = 10
	add_theme_stylebox_override("normal", style_normal)

	# Hover
	var style_hover := style_normal.duplicate() as StyleBoxFlat
	style_hover.bg_color = hover_color
	add_theme_stylebox_override("hover", style_hover)

	# Pressed
	var style_pressed := style_normal.duplicate() as StyleBoxFlat
	style_pressed.bg_color = pressed_color
	add_theme_stylebox_override("pressed", style_pressed)


func get_palette_color(role: ColorRole, custom: Color) -> Color:
	match role:
		ColorRole.PRIMARY:
			return Palette.get_color("primary")
		ColorRole.ACCENT:
			return Palette.get_color("accent")
		ColorRole.BACKGROUND:
			return Palette.get_color("background")
		ColorRole.SECONDARY:
			return Palette.get_color("secondary")
		ColorRole.CUSTOM:
			return custom
		_:
			return Color.WHITE
