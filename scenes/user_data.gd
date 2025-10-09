extends Node

var current_score: int = 0
var total_run_score: int = 0
var paused: bool = false


func get_reserved_dice() -> Node:
	var dice_reserve = []
	for i in $DiceReserve.get_children():
		dice_reserve.append(i)

	# select a random die from the reserve

	if dice_reserve.size() == 0:
		return null
	var random_index = randi() % dice_reserve.size()
	return dice_reserve[random_index]


func score(points: int) -> void:
	current_score += points
	total_run_score += points
