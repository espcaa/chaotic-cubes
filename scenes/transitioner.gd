extends CanvasLayer

var next_scene: PackedScene = null
var next_scene_instance: Node = null
var nuking_scene: Node = null


func load_scene_with_transition(
	scene_path: String, calling_scene: Node, color: Enums.ColorRole
) -> void:
	# Load and instantiate the target scene
	next_scene = load(scene_path)
	next_scene_instance = next_scene.instantiate()
	nuking_scene = calling_scene

	# Set the transition color with the shader parameter

	var transition_color: Color

	match color:
		Enums.ColorRole.PRIMARY:
			transition_color = Palette.get_color("primary")
		Enums.ColorRole.ACCENT:
			transition_color = Palette.get_color("accent")
		Enums.ColorRole.BACKGROUND:
			transition_color = Palette.get_color("background")
		Enums.ColorRole.SECONDARY:
			transition_color = Palette.get_color("secondary")
		Enums.ColorRole.CUSTOM:
			transition_color = Color(1, 1, 1)  # Default to white if custom
		_:
			transition_color = Color(1, 1, 1)  # Default to white if unknown

	$in.material.set_shader_parameter("dot_color", transition_color)

	$AnimationPlayer.play("in")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "in" and next_scene_instance != null:
		var current = get_tree().current_scene
		if current != null:
			current.queue_free()  # Free the old scene completely
		get_tree().get_root().add_child(next_scene_instance)
		get_tree().set_current_scene(next_scene_instance)
		next_scene_instance = null
		$AnimationPlayer.play("out")
