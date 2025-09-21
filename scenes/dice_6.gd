extends "res://scenes/dice.gd"


func roll():
	$CustomLabel.label_text = "6 :D"
	value.append(6)
	emit_signal("roll_finished")
	$AnimationPlayer.play("text")
