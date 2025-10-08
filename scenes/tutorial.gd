extends Control


class TutorialStep:
	var description: String
	var keys_to_press: Array[String]
	var time_to_wait: float = 1.0

	func _init(desc: String, keys: Array[String], time: float = 0.0) -> void:
		description = desc
		keys_to_press = keys
		time_to_wait = time


var steps: Array[TutorialStep] = [
	(
		TutorialStep
		. new(
			"welcome to chaotic cubes :D",
			[],
			2.0,
		)
	),
	(
		TutorialStep
		. new(
			"Use [img]res://assets/button-arrow-left.png[/img] and [img]res://assets/button-arrow-right.png[/img] to select dices!",
			["left", "right"],
		)
	),
	(
		TutorialStep
		. new(
			"click on [img]res://assets/button-enter.png[/img] to play the current dice :D",
			["play"],
		)
	),
	(
		TutorialStep
		. new(
			"use [img]res://assets/button-tab.png[/img] to get a new random dice!!",
			["draw"],
		)
	),
	(
		TutorialStep
		. new(
			"Press [img]res://assets/button-arrow-down.png[/img] to remove the selected dice!",
			["remove_dice"],
		)
	),
	(
		TutorialStep
		. new(
			"now, your goal is to hit 200 points ;D",
			[],
			5.0,
		)
	),
]

var current_step_index: int = -1


func _ready() -> void:
	complete_step()


func complete_step() -> void:
	if current_step_index < steps.size() - 1:
		current_step_index += 1
		update_step()
	else:
		finish_tutorial()


func update_step() -> void:
	if current_step_index != 0:
		$AnimationPlayer.play("exit")
		await $AnimationPlayer.animation_finished
	var step = steps[current_step_index]

	$VBoxContainer/HBoxContainer/colored_container/MarginContainer/VBoxContainer/CustomRichLabel.label_text = (
		step.description
	)
	$AnimationPlayer.play("enter")
	if step.keys_to_press.size() == 0:
		await get_tree().create_timer(step.time_to_wait).timeout
		complete_step()


func finish_tutorial() -> void:
	$AnimationPlayer.play("exit")
	await $AnimationPlayer.animation_finished
	get_tree().get_first_node_in_group("gameui").is_tutorial = false
	self.queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var step = steps[current_step_index]
		for key in step.keys_to_press:
			if Input.is_action_pressed(key):
				complete_step()
				break
