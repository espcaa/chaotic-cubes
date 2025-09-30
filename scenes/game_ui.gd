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

var dice_queue := []


func _ready() -> void:
	Palette.assign_new_palette()
	cached_game_container_size = $HBoxContainer/VBoxContainer/game_container.size
	update_playing_pos()
	await get_tree().process_frame
	$HBoxContainer/VBoxContainer/game_container/drawing.position.y = (
		$HBoxContainer/VBoxContainer/separartor.position.y - 56 * 2
	)


func _process(_delta: float) -> void:
	$HBoxContainer/menu_bar/MarginContainer/VBoxContainer/colored_container2/MarginContainer/VBoxContainer/ScoreLabel.label_text = str(
		UserData.score
	)
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

	UserData.score += active_dice.value[0]

	await get_tree().create_timer(0.5).timeout  # wait a bit before moving to played area

	var tween = active_dice.create_tween()

	active_dice.reparent($"HBoxContainer/VBoxContainer/game_container/old_dices_container")
	var dice_size = 16 * active_dice.get_node("AnimatedSprite2D").scale
	update_dices_in_queue()

	# get the point where it should go :
	var new_pos_x = $MarginContainer/alr_played_container.size.x - dice_size.x + 5
	var new_pos_y = $MarginContainer/alr_played_container.size.y / 2 - 5

	tween.tween_property(active_dice, "global_position", Vector2(new_pos_x, new_pos_y), 0.3)

	await tween.finished

	# reparent

	active_dice.reparent($MarginContainer/alr_played_container)
	dice_queue.append(active_dice)

	active_dice = null
	playing_move = false
	dice_refresh_blocked = false
	if selected_index == 0:
		selected_index = 0
	else:
		select_index(selected_index - 1)
	redraw_screen()


func update_dices_in_queue():
	for i in dice_queue:
		var tween = i.create_tween()
		# Move the dices to the left by 16*scale pixel + 10px margin
		tween.tween_property(
			i, "position:x", i.position.x - (16 * i.get_node("AnimatedSprite2D").scale.x + 20), 0.2
		)

	if dice_queue.size() > 3:
		var first_dice = dice_queue.pop_front()
		first_dice.queue_free()


func update_playing_pos() -> void:
	dice_playing_pos = Vector2(
		cached_game_container_size.x / 2, cached_game_container_size.y / 2 + 60
	)
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
		play_audio_rollover()
		redraw_screen()

	if Input.is_action_just_pressed("right"):
		select_index(selected_index + 1)
		play_audio_rollover()
		redraw_screen()

	if Input.is_action_just_pressed("ui_accept") and not playing_move:
		var point = $HBoxContainer/VBoxContainer/dice_container/point
		if selected_index < point.get_child_count():
			active_dice = point.get_child(selected_index)
			dice_refresh_blocked = true
			playing_move = true
			move_active_dice()

	if Input.is_action_just_pressed("draw"):
		var newDice = UserData.get_reserved_dice()
		if newDice == null:
			return
		else:
			$HBoxContainer/menu_bar/MarginContainer/VBoxContainer/dice_machine.add_dice(
				newDice
			)


func play_audio_rollover():
	var pitch = randf_range(1, 1.5)
	$audio/rollover_audio.pitch_scale = pitch
	$audio/rollover_audio.play()


func add_dice(dice: Node2D, start_pos: Vector2 = Vector2.ZERO) -> void:
	dice_refresh_blocked = true

	var point = $HBoxContainer/VBoxContainer/dice_container/point
	dice.reparent(point)

	dice.global_position = start_pos
	dice.scale = Vector2(1, 1)

	var idx = point.get_child_count() - 1
	var target_pos = Vector2(idx * 85, cached_dice_container_height / 2)

	var tween = dice.create_tween()
	tween.tween_property(dice, "position", target_pos, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(
		Tween.EASE_OUT
	)

	(
		tween
		. tween_property(dice, "scale", Vector2(1.2, 1.2), 0.15)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_property(dice, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(
		Tween.EASE_OUT
	)

	dice_queue.append(dice)

	tween.tween_callback(func(): _on_dice_added(dice))


func _on_dice_added(dice: Node2D) -> void:
	dice_refresh_blocked = false
	dice.z_index = 10

	var point = $HBoxContainer/VBoxContainer/dice_container/point
	select_index(point.get_child_count() - 1)
	redraw_screen()
