extends RichTextLabel

enum ColorRole { PRIMARY, ACCENT, BACKGROUND, SECONDARY, TERTIARY, ERROR }

@export var color_role: ColorRole = ColorRole.PRIMARY
@export var font_size: int = 16
@export var label_text: String = "Label"

var cached_text: String = ""

var cached_color: Color = Color.WHITE


func _ready() -> void:
	bbcode_enabled = true
	text = label_text
	cached_text = label_text

	# Font size via DynamicFont + theme override
	add_theme_font_size_override("normal_font_size", font_size)

	var palette_color = get_palette_color(color_role)

	if cached_color != palette_color:
		cached_color = palette_color

	# Color via theme override

	# set the shader color

	set_instance_shader_parameter("primary_replaced_color", get_palette_color(ColorRole.ERROR))
	set_instance_shader_parameter(
		"background_replaced_color", get_palette_color(ColorRole.BACKGROUND)
	)
	set_instance_shader_parameter("accent_replaced_color", get_palette_color(ColorRole.ACCENT))
	set_instance_shader_parameter(
		"secondary_replaced_color", get_palette_color(ColorRole.SECONDARY)
	)


func _process(_delta: float) -> void:
	if cached_text != label_text:
		cached_text = label_text
		text = label_text

	var palette_color = get_palette_color(color_role)

	if cached_color != palette_color:
		set_instance_shader_parameter("primary_replaced_color", get_palette_color(ColorRole.ERROR))
		set_instance_shader_parameter("background_replaced_color", get_palette_color(color_role))
		set_instance_shader_parameter("accent_replaced_color", get_palette_color(ColorRole.ACCENT))
		set_instance_shader_parameter(
			"secondary_replaced_color", get_palette_color(ColorRole.SECONDARY)
		)

		cached_color = palette_color


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
