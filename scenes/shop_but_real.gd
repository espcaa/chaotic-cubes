extends "res://scenes/shop.gd"


func populate_dices():
	var shop_dices = []
	for i in range(3):
		var new_dice_scene = null
		while new_dice_scene == null or new_dice_scene in shop_dices:
			new_dice_scene = get_new_dice()
		shop_dices.append(new_dice_scene)

	for i in shop_dices:
		var new_dice_instance = i[0].instantiate()
		$dices/dice_container.add_child(new_dice_instance)


func get_new_dice():
	return UserData.RandomDiceManager.get_non_unlocked_dice_for_shop(UserData.unlocked_dices)
