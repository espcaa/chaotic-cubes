extends Button

enum ColorRole { CUSTOM, PRIMARY, ACCENT, BACKGROUND, SECONDARY, ERROR }

@export var bg_color: ColorRole = ColorRole.PRIMARY
@export var text_color: ColorRole = ColorRole.SECONDARY

@export var non_focused_outline_removed: bool = false
@export var focused_outline_removed: bool = false

# Optional custom colors
@export var custom_bg_color: Color = Color.TRANSPARENT
@export var custom_text_color: Color = Color.WHITE
@export var custom_hover_color: Color = Color(0.9, 0.9, 0.9)  # New export for hover color

# Hover + pressed background colors
@export var hover_color: ColorRole = ColorRole.CUSTOM  # Changed to use ColorRole
@export var pressed_color: Color = Color(0.7, 0.7, 0.7)

@export var font_size: int = 16
@export var label_text: String = "Label"

var cached_bg: Color = Color.TRANSPARENT
var cached_font: Color = Color.TRANSPARENT

var stylebox_normal: StyleBoxFlat
var stylebox_hover: StyleBoxFlat


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
	var hover_color_real = get_palette_color(hover_color, custom_hover_color)

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
	style_normal.content_margin_top = 5
	style_normal.content_margin_bottom = 5
	style_normal.set_corner_radius_all(0)
	add_theme_stylebox_override("normal", style_normal)

	if non_focused_outline_removed:
		style_normal.border_color = bg_color_real

	# Hover
	var style_hover := style_normal.duplicate() as StyleBoxFlat
	style_hover.bg_color = hover_color_real
	style_hover.border_color = bg_color_real

	if focused_outline_removed:
		style_hover.border_color = hover_color_real

	stylebox_hover = style_hover
	stylebox_normal = style_normal


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
		ColorRole.ERROR:
			return Palette.get_color("error")
		ColorRole.CUSTOM:
			return custom
		_:
			return Color.WHITE


func set_light_font_color() -> void:
	add_theme_color_override("font_color", cached_bg)


func set_dark_font_color() -> void:
	add_theme_color_override("font_color", cached_font)
