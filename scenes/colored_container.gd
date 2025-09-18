extends PanelContainer

enum ColorRole { PRIMARY, ACCENT, BACKGROUND, SECONDARY }

@export var color_role: ColorRole = ColorRole.PRIMARY

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

func set_bg_color():
	style_box.bg_color = cached_color
	self.add_theme_stylebox_override("panel", style_box)
