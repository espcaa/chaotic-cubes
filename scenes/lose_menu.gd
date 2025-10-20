extends Control


func play_lose_animation():
	UserData.paused = true
	UserData.can_pause = false
	$AnimationPlayer.play("lose")
	%LoseButtonContainer.active = true
