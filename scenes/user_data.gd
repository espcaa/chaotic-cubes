extends Node

var score: int = 0

func get_reserved_dice() -> Node:
	var dice_reserve = []
	for i in $DiceReserve.get_children():
		dice_reserve.append(i)

	# select a random die from the reserve

	if dice_reserve.size() == 0:
		return null
	var random_index = randi() % dice_reserve.size()
	return dice_reserve[random_index]
