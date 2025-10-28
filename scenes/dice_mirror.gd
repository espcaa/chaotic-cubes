extends "res://scenes/dice.gd"

@export var custom_dice_name: String = "mirror dice"
@export var custom_dice_description: String = "will always repeat the last number"

var dice_complete_description = "this dice reveals your true self... (actually no, it's just copying the last roll)"
var dice_lore = "is it a trick? or just magic?"


func roll():
	# get the last played value
	
	var last_value = get_tree().get_first_node_in_group("gameui").get_recent_dice_value()
	if playing:
		return  # prevent rolling multiple times

	$CustomLabel.label_text = str(last_value) + " mirorr!!"
	value.append(last_value)
	await get_tree().process_frame
	emit_signal("roll_finished")
	$AnimationPlayer.play("text")
	
func custom_ready() -> void:
	$AnimatedSprite2D.frame = 7


func set_dice_name():
	dice_name = custom_dice_name
	dice_description = custom_dice_description
