extends Control


func _input(event: InputEvent) -> void:
	# catch the "pause" action to toggle the pause menu
	if Input.is_action_just_pressed("pause") and not event.echo:
		if UserData.paused == false:
			$AnimationPlayer.play("pause")
			await $AnimationPlayer.animation_finished
			UserData.paused = true
		else:
			$AnimationPlayer.play_backwards("pause")
			await $AnimationPlayer.animation_finished
			UserData.paused = false
