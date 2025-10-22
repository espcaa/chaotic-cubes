extends Control

var shop_items: Array[Node] = []
var selected_dice: Node = null
@export var testing = true

@export var seed_color: Color = Color.REBECCA_PURPLE


func _ready() -> void:
	Palette.seed_color = seed_color
	Palette.assign_new_palette()
	
	for i in shop_items:
		$dices/dice_container.add_child(i)
	
	$temp/continue_button.reparent($dices/dice_container)

	for i in %dice_container.get_children():
		shop_items.append(i)
	

	selected_dice = shop_items[1]

	redraw_dices()

	await get_tree().process_frame


func redraw_dices():
	# the selected dice should be at 0,0
	for i in shop_items:
		var tween = create_tween()
		if i == selected_dice:
			(
				tween
				. tween_property(i, "scale", Vector2(1.2, 1.2), 0.055)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_IN_OUT)
			)
			tween.tween_property(i, "position:y", 0, 0.055)
		else:
			(
				tween
				. tween_property(i, "scale", Vector2(1, 1), 0.055)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_IN_OUT)
			)
			# it should be after or before, they have a height of 16*4
			var index = shop_items.find(i)
			var selected_index = shop_items.find(selected_dice)
			var offset = (index - selected_index) * 82
			tween.tween_property(i, "position:y", offset, 0.055)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		_select_next_dice()
		redraw_dices()
	elif event.is_action_pressed("up"):
		_select_previous_dice()
		redraw_dices()


func _select_next_dice() -> void:
	var current_index = shop_items.find(selected_dice)
	var next_index = (current_index + 1) % shop_items.size()
	selected_dice = shop_items[next_index]


func _select_previous_dice() -> void:
	var current_index = shop_items.find(selected_dice)
	var next_index = (current_index - 1 + shop_items.size()) % shop_items.size()
	selected_dice = shop_items[next_index]
