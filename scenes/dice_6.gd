extends "res://scenes/dice.gd"


func roll():
	$CustomLabel.label_text = "6 :D"
	value.append(6)
	await get_tree().process_frame
	emit_signal("roll_finished")
	$AnimationPlayer.play("text")
