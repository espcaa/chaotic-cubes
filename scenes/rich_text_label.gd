extends RichTextLabel

enum ColorRole { PRIMARY, ACCENT, BACKGROUND, SECONDARY, TERTIARY, ERROR }

@export var color_role: ColorRole = ColorRole.PRIMARY
@export var font_size: int = 16
@export var label_text: String = "Label"

var cached_text: String = ""
var cached_color: Color = Color.WHITE


func _ready() -> void:
	bbcode_enabled = true
	update_text(label_text)

	add_theme_font_size_override("normal_font_size", font_size)

	update_shader_colors()
	add_theme_color_override("default_color", get_palette_color(color_role))


func _process(_delta: float) -> void:
	if cached_text != label_text:
		update_text(label_text)

	var palette_color = get_palette_color(color_role)
	if cached_color != palette_color:
		update_shader_colors()
		add_theme_color_override("default_color", palette_color)
		cached_color = palette_color


# --- HELPER FUNCTIONS ---


func colorize_text(raw_text: String) -> String:
	var hex_color = cached_color.to_html(false)  # no alpha
	return "[color=#%s]%s[/color]" % [hex_color, raw_text]


func update_text(new_text: String) -> void:
	cached_text = new_text
	text = colorize_text(new_text)


func update_shader_colors() -> void:
	set_instance_shader_parameter("primary_replaced_color", get_palette_color(ColorRole.ERROR))
	set_instance_shader_parameter(
		"background_replaced_color", get_palette_color(ColorRole.BACKGROUND)
	)
	set_instance_shader_parameter("accent_replaced_color", get_palette_color(ColorRole.ACCENT))
	set_instance_shader_parameter(
		"secondary_replaced_color", get_palette_color(ColorRole.SECONDARY)
	)


func get_palette_color(color_thingy) -> Color:
	match color_thingy:
		ColorRole.PRIMARY:
			return Palette.get_color("primary")
		ColorRole.ACCENT:
			return Palette.get_color("accent")
		ColorRole.BACKGROUND:
			return Palette.get_color("background")
		ColorRole.SECONDARY:
			return Palette.get_color("secondary")
		ColorRole.TERTIARY:
			return Palette.get_color("tertiary")
		ColorRole.ERROR:
			return Palette.get_color("error")
		_:
			return Color.WHITE
