extends Control



func _ready() -> void:
	Palette.assign_new_palette()
	for i in $Control/MarginContainer/VBoxContainer/button_container.get_children():
		if i is Button:
			i.pressed.connect(func(): _change_color(i))  # anonymous lambda


func _change_color(node: Button) -> void:
	Palette.change_base_color(node.custom_bg_color)


func _on_custom_button_pressed() -> void:
	Transitioner.load_scene_with_transition("res://scenes/game_ui.tscn", self, Enums.ColorRole.SECONDARY)
