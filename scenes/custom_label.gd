extends Label

enum ColorRole { PRIMARY, ACCENT, BACKGROUND, SECONDARY }

@export var color_role: ColorRole = ColorRole.PRIMARY
@export var font_size: int = 16
@export var label_text: String = "Label"

var cached_text: String = ""

var cached_color: Color = Color.WHITE


func _ready() -> void:
	text = label_text
	cached_text = label_text

	# Font size via DynamicFont + theme override
	add_theme_font_size_override("font_size", font_size)

	var palette_color = get_palette_color()

	if cached_color != palette_color:
		cached_color = palette_color

	# Color via theme override
	add_theme_color_override("font_color", get_palette_color())

func _process(_delta: float) -> void:
	if cached_text != label_text:
		cached_text = label_text
		text = label_text

	var palette_color = get_palette_color()

	if cached_color != palette_color:
		cached_color = palette_color
		add_theme_color_override("font_color", get_palette_color())


func get_palette_color() -> Color:
	match color_role:
		ColorRole.PRIMARY:
			return Palette.get_color("primary")
		ColorRole.ACCENT:
			return Palette.get_color("accent")
		ColorRole.BACKGROUND:
			return Palette.get_color("background")
		ColorRole.SECONDARY:
			return Palette.get_color("secondary")
		_:
			return Color.WHITE
