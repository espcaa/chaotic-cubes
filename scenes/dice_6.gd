extends "res://scenes/dice.gd"

@export var number: int = 6

@export var custom_dice_name = "static dice"
@export var custom_dice_description = "this dice will always be the same"
var dice_lore = "some purple wizzard froze this dice's value forever..."


func custom_ready() -> void:
	$AnimatedSprite2D.frame = number - 1


func roll():
	$CustomLabel.label_text = str(number) + " :D"
	value.append(number)
	await get_tree().process_frame
	emit_signal("roll_finished")
	$AnimationPlayer.play("text")


func set_dice_name():
	dice_name = custom_dice_name
	dice_description = custom_dice_description
