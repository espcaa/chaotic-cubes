extends Node

var rarity_weights = {"common": 80, "rare": 15, "legendary": 5}

var all_dices = {
	"common":
	{
		"dice_1": {"weight": 10.0},
		"dice_2": {"weight": 10.0},
		"dice_3": {"weight": 10.0},
		"dice_4": {"weight": 10.0},
		"dice_5": {"weight": 10.0},
		"dice_6": {"weight": 10.0},
		"normal_dice": {"weight": 100.0},
	},
	"rare":
	{
		"firedice": {"weight": 1.0},
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
	"firedice": load("res://scenes/dice_fire.tscn")
}


func get_random_dice(unlocked_array: Array) -> Dictionary:
	if unlocked_array.size() == 0:
		push_warning("No unlocked dice available...")
		return {}

	var selected_rarity = ""
	var filtered_dice_list = []

	while filtered_dice_list.size() == 0:
		var total_weight = 0.0
		for weight in rarity_weights.values():
			total_weight += weight

		var random_value = randf() * total_weight
		var cumulative_weight = 0.0
		for rarity in rarity_weights.keys():
			cumulative_weight += rarity_weights[rarity]
			if random_value < cumulative_weight:
				selected_rarity = rarity
				break

		filtered_dice_list.clear()
		for dice_name in all_dices[selected_rarity].keys():
			if dice_name in unlocked_array:
				filtered_dice_list.append(dice_name)

	var total_dice_weight = 0.0
	var cumulative_weights = []
	for dice_name in filtered_dice_list:
		var weight = all_dices[selected_rarity][dice_name]["weight"]
		total_dice_weight += weight
		cumulative_weights.append(total_dice_weight)

	var dice_roll = randf() * total_dice_weight
	for i in range(cumulative_weights.size()):
		if dice_roll < cumulative_weights[i]:
			var selected_dice = filtered_dice_list[i]
			return {"string_name": selected_dice, "scene": dice_to_scene[selected_dice]}

	var fallback_dice = filtered_dice_list.back()
	return {"string_name": fallback_dice, "scene": dice_to_scene[fallback_dice]}
