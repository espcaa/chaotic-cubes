extends Node

var current_score: int = 0
var total_run_score: int = 0
var paused: bool = false
var time_run: float = 0.0
var timer_running: bool = false
var money: int = 0
var can_pause: bool = true

var current_seed : Color

@onready var RandomDiceManager = $RandomDiceManager

var unlocked_dices = ["normal_dice"]

func _process(delta: float) -> void:
	if not paused and timer_running:
		time_run += delta * 10.0


func get_reserved_dice() -> Node:
	# first get a random dice
	var dice_scene = RandomDiceManager.get_random_dice(unlocked_dices)

	if dice_scene == null:
		push_warning("No dice scene returned...")
		return null

	var dice_instance = dice_scene.instantiate()
	return dice_instance


func score(points: int) -> void:
	current_score += points
	total_run_score += points


func reset_time() -> void:
	time_run = 0.0
	timer_running = true


func reset_game() -> void:
	current_score = 0
	total_run_score = 0
	time_run = 0.0
	timer_running = false
	paused = false
	money = 0
	can_pause = true
