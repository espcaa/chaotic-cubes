extends Control

var cached_dice_container_height: float = 0.0
var cached_game_container_size: Vector2
var dice_y_base: float = 0.0
var dice_playing_pos: Vector2

var target_x: float = 0.0
var selected_index: int = 0

var playing_move := false
var dice_refresh_blocked := false
var active_dice: Node = null


func _ready() -> void:
	Palette.assign_new_palette()
	cached_game_container_size = $HBoxContainer/VBoxContainer/game_container.size
	update_playing_pos()


func _process(_delta: float) -> void:
	update_on_resize()


func update_on_resize() -> void:
	var dice_container = $HBoxContainer/VBoxContainer/dice_container
	var game_container = $HBoxContainer/VBoxContainer/game_container

	var needs_redraw := false

	if cached_dice_container_height != dice_container.size.y:
		cached_dice_container_height = dice_container.size.y
		needs_redraw = true

	if cached_game_container_size != game_container.size:
		cached_game_container_size = game_container.size
		update_playing_pos()
		needs_redraw = true

	if needs_redraw:
		redraw_screen()


func update_point_position() -> void:
	var point = $HBoxContainer/VBoxContainer/dice_container/point
	(
		point
		. create_tween()
		. tween_property(point, "position:x", target_x, 0.2)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)


func move_active_dice() -> void:
	if not playing_move or active_dice == null:
		return

	var tween = active_dice.create_tween()
	(
		tween
		. tween_property(active_dice, "global_position", dice_playing_pos, 0.3)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN_OUT)
	)
	tween.tween_callback(Callable(self, "_on_dice_reached_center"))


func _on_dice_reached_center() -> void:
	if active_dice == null:
		return

	# roll the dice

	active_dice.roll()
	await active_dice.roll_finished
	# =ove to 10, 10 local position

	var tween = active_dice.create_tween()

	active_dice.reparent($"HBoxContainer/VBoxContainer/game_container/old_dices_container")
	tween.tween_property(active_dice, "position", Vector2(10, 10), 0.3)
	await tween.finished
	active_dice = null
	playing_move = false
	dice_refresh_blocked = false
	if selected_index == 0:
		selected_index = 0
	else:
		select_index(selected_index - 1)
	redraw_screen()


func update_playing_pos() -> void:
	dice_playing_pos = cached_game_container_size / 2
	$"HBoxContainer/VBoxContainer/game_container/center_dice_point".position = dice_playing_pos


func redraw_screen() -> void:
	if dice_refresh_blocked:
		return
	draw_dices()


func draw_dices() -> void:
	var point = $HBoxContainer/VBoxContainer/dice_container/point
	target_x = $HBoxContainer/VBoxContainer/dice_container.size.x / 2 + selected_index * -80
	update_point_position()

	for i in point.get_children():
		var idx = i.get_index()
		var tween = i.create_tween()
		if idx == selected_index:
			(
				tween
				. tween_property(i, "scale", Vector2(1.2, 1.2), 0.15)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_OUT)
			)
		else:
			(
				tween
				. tween_property(i, "scale", Vector2(1, 1), 0.15)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_OUT)
			)
		tween.tween_property(
			i, "position", Vector2(idx * 85, cached_dice_container_height / 2), 0.15
		)


func select_index(new_index: int) -> void:
	var point = $HBoxContainer/VBoxContainer/dice_container/point
	var count = point.get_child_count()

	if count == 0:
		selected_index = 0
	else:
		var wrapped = new_index % count
		if wrapped < 0:
			wrapped += count
		selected_index = wrapped


func _input(event: InputEvent) -> void:
	if dice_refresh_blocked:
		return

	if Input.is_action_just_pressed("left"):
		select_index(selected_index - 1)
		redraw_screen()

	if Input.is_action_just_pressed("right"):
		select_index(selected_index + 1)
		redraw_screen()

	if Input.is_action_just_pressed("ui_accept") and not playing_move:
		var point = $HBoxContainer/VBoxContainer/dice_container/point
		if selected_index < point.get_child_count():
			active_dice = point.get_child(selected_index)
			dice_refresh_blocked = true
			playing_move = true
			move_active_dice()
