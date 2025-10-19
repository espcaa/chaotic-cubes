extends Control


func _input(event: InputEvent) -> void:
	# catch the "pause" action to toggle the pause menu
	if Input.is_action_just_pressed("pause") and not event.echo:
		if UserData.paused == false:
			pause_game()
		else:
			await unpause_game()


func unpause_game() -> void:
	$AnimationPlayer.play_backwards("pause")
	await $AnimationPlayer.animation_finished
	UserData.paused = false


func pause_game() -> void:
	$AnimationPlayer.play("pause")
	UserData.paused = true


func _process(_delta: float) -> void:
	$colored_container/MarginContainer/HBoxContainer/MarginContainer/colored_container/MarginContainer/VBoxContainer/LabelTotalScore.text = (
		"Total points during this run : " + str(UserData.total_run_score)
	)
	$colored_container/MarginContainer/HBoxContainer/MarginContainer/colored_container/MarginContainer/VBoxContainer/LabelTotalTime.text = (
		"Total time played : " + str(round(UserData.time_run)) + " seconds"
	)
	$colored_container/MarginContainer/HBoxContainer/MarginContainer/colored_container/MarginContainer/VBoxContainer/LabelTotalMoney.text = (
		"All of the money ever earned: " + str(UserData.money)
	)


func _on_quit_pressed() -> void:
	Transitioner.load_scene_with_transition(
		"res://scenes/main_menu.tscn", get_parent(), Enums.ColorRole.SECONDARY
	)


func _on_resume_pressed() -> void:
	await unpause_game()
