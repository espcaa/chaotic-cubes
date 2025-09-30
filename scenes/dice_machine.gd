extends Control

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
	$Bg.set_instance_shader_parameter("primary_replaced_color", cached_primary)
	$Bg.set_instance_shader_parameter("accent_replaced_color", cached_accent)
	$Bg.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)
	$Bg.set_instance_shader_parameter("background_replaced_color", cached_background)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var primary = Palette.get_color("primary")
	var accent = Palette.get_color("accent")
	var secondary = Palette.get_color("tertiary")
	var background = Palette.get_color("background")
	if cached_primary != primary:
		cached_primary = primary
		$Bg.set_instance_shader_parameter("primary_replaced_color", cached_primary)
	if cached_accent != accent:
		cached_accent = accent
		$Bg.set_instance_shader_parameter("accent_replaced_color", cached_accent)
	if cached_secondary != secondary:
		cached_secondary = secondary
		$Bg.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)
	if cached_background != background:
		cached_background = background
		$Bg.set_instance_shader_parameter("background_replaced_color", cached_background)

	if current_dice and is_instance_valid(current_dice):
		if current_dice.stopped:
			dice_settled(current_dice)


func add_dice(node: Node) -> void:
	if adding_dice != true:
		adding_dice = true
		var newPhysicDice = load("res://scenes/dice_body.tscn").instantiate()
		$Polygon2D.add_child(newPhysicDice)
		node.reparent(newPhysicDice)
		node.position = Vector2.ZERO
		newPhysicDice.position.x = 64
		newPhysicDice.position.y = -164
		node.z_index = 0
		current_dice = newPhysicDice


func dice_settled(dice: RigidBody2D) -> void:
	dice.get_child(2).z_index = 200

	get_tree().get_first_node_in_group("gameui").add_dice(dice.get_child(2),dice.global_position)
	dice.queue_free()
	current_dice = null
	adding_dice = false
