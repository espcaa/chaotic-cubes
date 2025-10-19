extends TextureRect


var cached_primary: Color = Color.WHITE
var cached_accent: Color = Color.WHITE
var cached_secondary: Color = Color.WHITE
var cached_background: Color = Color.WHITE

var adding_dice: bool = false

var current_dice: RigidBody2D = null


func _ready() -> void:
	cached_primary = Palette.get_color("primary")
	cached_accent = Palette.get_color("accent")
	cached_secondary = Palette.get_color("secondary")
	cached_background = Palette.get_color("background")
	self.set_instance_shader_parameter("primary_replaced_color", cached_primary)
	self.set_instance_shader_parameter("accent_replaced_color", cached_accent)
	self.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)
	self.set_instance_shader_parameter("background_replaced_color", cached_background)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var primary = Palette.get_color("primary")
	var accent = Palette.get_color("accent")
	var secondary = Palette.get_color("primary")
	var background = Palette.get_color("background")
	if cached_primary != primary:
		cached_primary = primary
		self.set_instance_shader_parameter("primary_replaced_color", cached_primary)
	if cached_accent != accent:
		cached_accent = accent
		self.set_instance_shader_parameter("accent_replaced_color", cached_accent)
	if cached_secondary != secondary:
		cached_secondary = secondary
		self.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)
	if cached_background != background:
		cached_background = background
		self.set_instance_shader_parameter("background_replaced_color", cached_background)
