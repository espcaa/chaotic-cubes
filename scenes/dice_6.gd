extends "res://scenes/dice.gd"

@export var number : int = 6

func custom_ready() -> void:
	$AnimatedSprite2D.frame = number - 1 

func roll():
	$CustomLabel.label_text = str(number) + " :D"
	value.append(number)
	await get_tree().process_frame
	emit_signal("roll_finished")
	$AnimationPlayer.play("text")
