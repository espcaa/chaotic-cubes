extends Control


func _ready() -> void:
	Palette.assign_new_palette()
	for i in $Control/MarginContainer/VBoxContainer/button_container.get_children():
		if i is Button:
			i.pressed.connect(func(): _change_color(i))  # anonymous lambda


func _change_color(node: Button) -> void:
	Palette.change_base_color(node.custom_bg_color)


func _on_custom_button_pressed() -> void:
	# load the scene + starts the timer

	UserData.timer_running = true
	Transitioner.load_scene_with_transition(
		"res://scenes/first_level_game_ui.tscn", self, Enums.ColorRole.SECONDARY
	)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
