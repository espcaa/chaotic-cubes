extends "res://scenes/dice.gd"

@export var custom_dice_name: String = "golden dice!"
@export var custom_dice_description: String = "just a regular dice.."
var dice_complete_description = "woa this dice is shiny... it must be worth a lot!!"
var dice_lore = "might be made of gold?"


func roll():
	if playing:
		return  # prevent rolling multiple times

	playing = true
	var duration = 1.0
	var step = 0.15
	var elapsed = 0.0
	var last_face = -1

	while elapsed < duration:
		# Ensure a different face is shown
		var new_face = faces[randi() % faces.size()]
		while new_face == last_face and faces.size() > 1:
			new_face = faces[randi() % faces.size()]
		$AnimatedSprite2D.frame = new_face
		play_woosh()
		await get_tree().create_timer(step).timeout
		elapsed += step

	# Stop rolling
	playing = false
	$CustomLabel.label_text = str($AnimatedSprite2D.frame + 1) + " !!"
	value.append($AnimatedSprite2D.frame + 1)  # +1 because frames are 0-based
	emit_signal("roll_finished")
	$AnimationPlayer.play("text")


func set_dice_name():
	dice_name = custom_dice_name
	dice_description = custom_dice_description
