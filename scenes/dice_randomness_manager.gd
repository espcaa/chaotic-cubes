extends Node

var rarity_weights = {"common": 80, "rare": 60, "epic": 40}

var all_dices = {
	"common":
	{
		"dice_1": {"weight": 10.0, "price": 100},
		"dice_2": {"weight": 10.0, "price": 100},
		"dice_3": {"weight": 10.0, "price": 100},
		"dice_4": {"weight": 10.0, "price": 100},
		"dice_5": {"weight": 10.0, "price": 100},
		"dice_6": {"weight": 10.0, "price": 100},
		"normal_dice": {"weight": 100.0, "price": 150},
	},
	"rare":
	{
		"pridedice": {"weight": 0.5, "price": 500},
		"d4": {"weight": 1.0, "price": 400},
		"flowerdice": {"weight": 0.7, "price": 600},
		"mirrordice" : {"weight": 0.8, "price": 600},
	},
	"epic":
	{
		"firedice": {"weight": 1.0, "price": 1000},
		"golden_dice": {"weight": 3.0, "price": 1500},
	}
}

var dice_to_scene = {
	"dice_1": load("res://scenes/dice_1.tscn"),
	"dice_2": load("res://scenes/dice_2.tscn"),
	"dice_3": load("res://scenes/dice_3.tscn"),
	"dice_4": load("res://scenes/dice_4.tscn"),
	"dice_5": load("res://scenes/dice_5.tscn"),
	"dice_6": load("res://scenes/dice_6.tscn"),
	"normal_dice": load("res://scenes/dice_normal.tscn"),
	"firedice": load("res://scenes/dice_fire.tscn"),
	"pridedice": load("res://scenes/pride_dice.tscn"),
	"d4": load("res://scenes/d_4.tscn"),
	"golden_dice": load("res://scenes/golden_dice.tscn"),
	"flowerdice": load("res://scenes/dice_flower.tscn"),
	"mirrordice" : load("res://scenes/dice_mirror.tscn")
}


func get_random_dice(unlocked_array: Array) -> PackedScene:
	if unlocked_array.is_empty():
		push_warning("No unlocked dice available...")
		return null

	var total_rarity_weight = 0.0
	for weight in rarity_weights.values():
		total_rarity_weight += weight

	var rand_val = randf() * total_rarity_weight
	var cumulative = 0.0
	var selected_rarity = ""
	for rarity in rarity_weights.keys():
		cumulative += rarity_weights[rarity]
		if rand_val < cumulative:
			selected_rarity = rarity
			break

	var available_dice = []
	for dice_name in all_dices[selected_rarity].keys():
		if dice_name in unlocked_array:
			available_dice.append(dice_name)

	if available_dice.is_empty():
		push_warning("No unlocked dice in selected rarity, returning first unlocked dice...")
		return dice_to_scene[unlocked_array[0]]

	var total_dice_weight = 0.0
	for dice_name in available_dice:
		total_dice_weight += all_dices[selected_rarity][dice_name]["weight"]

	var dice_rand = randf() * total_dice_weight
	cumulative = 0.0
	for dice_name in available_dice:
		cumulative += all_dices[selected_rarity][dice_name]["weight"]
		if dice_rand < cumulative:
			return dice_to_scene[dice_name]

	return dice_to_scene[available_dice.back()]


func get_non_unlocked_dice_for_shop(unlocked_array: Array) -> Array:
	var non_unlocked_dice = []

	for rarity in all_dices.keys():
		for dice_name in all_dices[rarity].keys():
			if dice_name not in unlocked_array:
				non_unlocked_dice.append(dice_name)

	if non_unlocked_dice.is_empty():
		push_warning("All dice unlocked, returning null...")
		return [null, "no_dice", 0]

	var selected_dice_name = non_unlocked_dice[randi() % non_unlocked_dice.size()]

	return [
		dice_to_scene[selected_dice_name],
		"success",
		all_dices[get_dice_rarity(selected_dice_name)][selected_dice_name]["price"]
	]


func get_dice_rarity(dice_name: String) -> String:
	for rarity in all_dices.keys():
		if dice_name in all_dices[rarity]:
			return rarity
	return "unknown"
