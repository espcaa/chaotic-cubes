extends Control


func _input(event: InputEvent) -> void:
	# catch the "pause" action to toggle the pause menu
	if Input.is_action_just_pressed("pause") and not event.echo:
		if UserData.paused == false:
			pause_game()
		else:
			await unpause_game()


func _on_quit_button_pressed() -> void:
	Transitioner.load_scene_with_transition(
		"res://scenes/main_menu.tscn", self, Enums.ColorRole.SECONDARY
	)


func _on_resume_button_pressed() -> void:
	await unpause_game()


func unpause_game() -> void:
	$AnimationPlayer.play_backwards("pause")
	await $AnimationPlayer.animation_finished
	UserData.paused = false


func pause_game() -> void:
	$AnimationPlayer.play("pause")
	UserData.paused = true


func _process(_delta: float) -> void:
	$colored_container/MarginContainer/HBoxContainer/VBoxContainer2/RightCustomRichLabelTotal.text = (
		"Total points during this run : " + str(UserData.total_run_score)
	)
	$colored_container/MarginContainer/HBoxContainer/VBoxContainer2/RightCustomRichLabelTimePlayed.text = (
		"Time played : " + str(round(UserData.time_run) / 60.0) + " minutes"
	)
	$colored_container/MarginContainer/HBoxContainer/VBoxContainer2/RightCustomRichLabelMoney.text = (
		"Current points : " + str(UserData.current_score)
	)
