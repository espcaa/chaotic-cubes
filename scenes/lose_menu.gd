extends Control


func play_lose_animation():
	UserData.paused = true
	UserData.can_pause = false
	$AnimationPlayer.play("lose")
	%LoseButtonContainer.active = true
	%LoseButtonContainer.reset()


func _on_quit_pressed() -> void:
	UserData.reset_game()
	Transitioner.load_scene_with_transition(
		"res://scenes/main_menu.tscn", self, Enums.ColorRole.SECONDARY
	)


func _on_restart_pressed() -> void:
	UserData.reset_game()
	Transitioner.load_scene_with_transition(
		"res://scenes/first_level_game_ui.tscn", self, Enums.ColorRole.SECONDARY
	)
