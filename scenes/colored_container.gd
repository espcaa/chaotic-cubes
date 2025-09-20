extends PanelContainer

enum ColorRole { PRIMARY, ACCENT, BACKGROUND, SECONDARY }

@export var color_role: ColorRole = ColorRole.PRIMARY
@export var corner_radius: float = 0.0       # 0 = no rounding
@export var outline_enabled: bool = false
@export var outline_color_role: ColorRole = ColorRole.ACCENT
@export var outline_thickness: float = 2.0   # thickness of outline

var cached_color: Color = Color.ALICE_BLUE
var style_box: StyleBoxFlat = StyleBoxFlat.new() 

func _ready() -> void:
	cached_color = get_palette_color()
	set_bg_color()

func _process(delta: float) -> void:
	var new_color = get_palette_color()
	if cached_color != new_color:
		cached_color = new_color
		set_bg_color()

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
			return Color.ALICE_BLUE 

func get_outline_color() -> Color:
	match outline_color_role:
		ColorRole.PRIMARY:
			return Palette.get_color("primary")
		ColorRole.ACCENT:
			return Palette.get_color("accent")
		ColorRole.BACKGROUND:
			return Palette.get_color("background")
		ColorRole.SECONDARY:
			return Palette.get_color("secondary")
		_:
			return Color.BLACK

func set_bg_color():
	# Base color
	style_box.bg_color = cached_color

	# Rounded corners
	style_box.corner_radius_top_left = corner_radius
	style_box.corner_radius_top_right = corner_radius
	style_box.corner_radius_bottom_left = corner_radius
	style_box.corner_radius_bottom_right = corner_radius

	# Outline
	if outline_enabled:
		var outline_color = get_outline_color()
		style_box.border_width_top = outline_thickness
		style_box.border_width_bottom = outline_thickness
		style_box.border_width_left = outline_thickness
		style_box.border_width_right = outline_thickness
		style_box.border_color = outline_color
	else:
		style_box.border_width_top = 0
		style_box.border_width_bottom = 0
		style_box.border_width_left = 0
		style_box.border_width_right = 0

	# Apply style
	self.add_theme_stylebox_override("panel", style_box)
