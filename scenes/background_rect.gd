extends TextureRect

@export var primary_key: String = "primary"
@export var accent_key: String = "accent"
@export var secondary_key: String = "secondary"
@export var background_key: String = "background"

var cached_primary: Color = Color.WHITE
var cached_accent: Color = Color.WHITE
var cached_secondary: Color = Color.WHITE
var cached_background: Color = Color.WHITE

var adding_dice: bool = false
var current_dice: RigidBody2D = null

func _ready() -> void:
	cached_primary = Palette.get_color(primary_key)
	cached_accent = Palette.get_color(accent_key)
	cached_secondary = Palette.get_color(secondary_key)
	cached_background = Palette.get_color(background_key)
	
	self.set_instance_shader_parameter("primary_replaced_color", cached_primary)
	self.set_instance_shader_parameter("accent_replaced_color", cached_accent)
	self.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)
	self.set_instance_shader_parameter("background_replaced_color", cached_background)

func _process(_delta: float) -> void:
	var primary = Palette.get_color(primary_key)
	var accent = Palette.get_color(accent_key)
	var secondary = Palette.get_color(secondary_key)
	var background = Palette.get_color(background_key)
	
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
