extends Node2D

var cached_primary: Color = Color.WHITE
var cached_accent: Color = Color.WHITE
var ColorRole = preload("res://assets/enums.gd").ColorRole


func _ready() -> void:
	cached_primary = Palette.get_color("primary")
	cached_accent = Palette.get_color("accent")
	$Bg.set_instance_shader_parameter("first_replaced_color", cached_accent)
	$Bg.set_instance_shader_parameter("second_replaced_color", cached_primary)


func _process(_delta: float) -> void:
	var primary = Palette.get_color("primary")
	var accent = Palette.get_color("accent")
	if cached_primary != primary:
		cached_primary = primary
		$Bg.set_instance_shader_parameter("first_replaced_color", cached_accent)
	if cached_accent != accent:
		cached_accent = accent
		$Bg.set_instance_shader_parameter("second_replaced_color", cached_primary)
