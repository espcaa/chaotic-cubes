extends Control

var shop_items: Array[Node] = []
var selected_dice: Node = null
@export var testing := true
@export var seed_color: Color = Color.REBECCA_PURPLE

var dict_dice_to_info_containers: Dictionary = {}

const ANIM_TIME := 0.25
const DICE_OFFSET := 82
const INFO_OFFSET := 360

var cached_primary: Color = Color.WHITE
var cached_secondary: Color = Color.WHITE


func _ready() -> void:
	populate_dices()
	cached_primary = Palette.get_color("primary")
	cached_secondary = Palette.get_color("tertiary")
	$basketicon.set_instance_shader_parameter("primary_replaced_color", cached_primary)
	$basketicon.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)

	Palette.seed_color = seed_color
	Palette.assign_new_palette()

	for i in shop_items:
		$dices/dice_container.add_child(i)

	$temp/continue_button.reparent($dices/dice_container)

	for i in %dice_container.get_children():
		shop_items.append(i)
	
	if shop_items.size() > 1:
		selected_dice = shop_items[1]
	else:
		selected_dice = shop_items[0]

	await get_tree().process_frame

	%continue_button.position.x = -%continue_button.size.x / 2

	for i in shop_items:
		if i is Button == false:
			var new_info = load("res://scenes/dice_info_shop.tscn").instantiate()
			$infopoint.add_child(new_info)
			dict_dice_to_info_containers[i] = new_info
		else:
			%continue_btn_info.reparent($infopoint)
			dict_dice_to_info_containers[i] = %continue_btn_info
	redraw_dices(true)

	await get_tree().process_frame

	# for each dice, get their dice_description and apply it to the shop info container
	for i in shop_items:
		var info = dict_dice_to_info_containers[i]
		if i is Button == false:
			info.dice_name = i.dice_name
			# check if it has a .lore
			if "dice_lore" in i:
				info.lore = i.dice_lore
			else:
				info.lore = "some lore? not here :("
			if "dice_complete_description" in i:
				info.description = i.dice_complete_description
			else:
				info.description = i.dice_description

	dict_dice_to_info_containers[selected_dice].buttons_active = true


func redraw_dices(_initial := false):
	for i in shop_items:
		i.get_tree().create_tween().kill()
		var info = dict_dice_to_info_containers[i]
		info.get_tree().create_tween().kill()

		var tween = create_tween()
		tween.set_parallel(true)

		if i == selected_dice:
			if not i is Button:
				(
					tween
					. tween_property(i, "scale", Vector2(1.15, 1.15), ANIM_TIME)
					. set_trans(Tween.TRANS_CUBIC)
					. set_ease(Tween.EASE_OUT)
				)
			(
				tween
				. tween_property(i, "position:y", 0, ANIM_TIME)
				. set_trans(Tween.TRANS_SINE)
				. set_ease(Tween.EASE_OUT)
			)
			(
				tween
				. tween_property(info, "position:y", 0, ANIM_TIME)
				. set_trans(Tween.TRANS_SINE)
				. set_ease(Tween.EASE_OUT)
			)
		else:
			(
				tween
				. tween_property(i, "scale", Vector2(1, 1), ANIM_TIME)
				. set_trans(Tween.TRANS_CUBIC)
				. set_ease(Tween.EASE_IN_OUT)
			)
			var offset = (shop_items.find(i) - shop_items.find(selected_dice)) * DICE_OFFSET
			var info_offset = (shop_items.find(i) - shop_items.find(selected_dice)) * INFO_OFFSET
			(
				tween
				. tween_property(i, "position:y", offset, ANIM_TIME)
				. set_trans(Tween.TRANS_SINE)
				. set_ease(Tween.EASE_OUT)
			)
			(
				tween
				. tween_property(info, "position:y", info_offset, ANIM_TIME)
				. set_trans(Tween.TRANS_SINE)
				. set_ease(Tween.EASE_OUT)
			)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("down"):
		if selected_dice is Button:
			_select_next_dice()
		elif not dict_dice_to_info_containers[selected_dice].modal_shown:
			_select_next_dice()
	elif event.is_action_pressed("up"):
		if selected_dice is Button:
			_select_previous_dice()
		elif not dict_dice_to_info_containers[selected_dice].modal_shown:
			_select_previous_dice()


func _select_next_dice() -> void:
	if selected_dice is Button == false:
		dict_dice_to_info_containers[selected_dice].buttons_active = false
	var current_index = shop_items.find(selected_dice)
	var next_index = (current_index + 1) % shop_items.size()
	selected_dice = shop_items[next_index]

	if selected_dice is Button == false:
		dict_dice_to_info_containers[selected_dice].buttons_active = true
	_apply_button_states()
	redraw_dices()


func _select_previous_dice() -> void:
	if selected_dice is Button == false:
		dict_dice_to_info_containers[selected_dice].buttons_active = false
	var current_index = shop_items.find(selected_dice)
	var next_index = (current_index - 1 + shop_items.size()) % shop_items.size()
	selected_dice = shop_items[next_index]
	_apply_button_states()

	if selected_dice is Button == false:
		dict_dice_to_info_containers[selected_dice].buttons_active = true

	redraw_dices()


func _apply_button_states():
	for i in shop_items:
		if i is Button:
			var btn := i
			if btn == selected_dice:
				btn.set_light_font_color()
				btn.focused = true
				btn.add_theme_stylebox_override("normal", btn.stylebox_hover)
			else:
				btn.set_dark_font_color()
				btn.focused = false
				btn.add_theme_stylebox_override("normal", btn.stylebox_normal)


func _process(_delta: float) -> void:
	if (
		cached_primary != Palette.get_color("primary")
		or cached_secondary != Palette.get_color("tertiary")
	):
		cached_primary = Palette.get_color("primary")
		cached_secondary = Palette.get_color("tertiary")
		$basketicon.set_instance_shader_parameter("primary_replaced_color", cached_primary)
		$basketicon.set_instance_shader_parameter("secondary_replaced_color", cached_secondary)


func disable_button_focus():
	dict_dice_to_info_containers[selected_dice].buttons_active = false


func enable_button_focus():
	dict_dice_to_info_containers[selected_dice].buttons_active = true


func populate_dices():
	pass
