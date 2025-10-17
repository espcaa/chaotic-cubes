extends "res://scenes/patterns.gd"

var cached_dice_container_height: float = 0.0
var cached_game_container_size: Vector2
var dice_y_base: float = 0.0
var dice_playing_pos: Vector2

var target_x: float = 0.0
var selected_index: int = 0

var dice_limit: int = 10

var playing_move := false
var dice_refresh_blocked := false
var active_dice: Node = null

var dice_queue := []

@export var boss: bool = false

@export var is_tutorial: bool = false

var is_drawing_a_dice: bool = false
var lost: bool = false
var won: bool = false
@export var goal: int = 1
@export var draw_limit: int = -1
@export var draw_used: int = 0
@export var machine_limit: int = -1
@export var machine_used: int = 0
@export var dice_max_limit: int = 10
@export var money_reward: int = 10
@export var seed_color: Color = Color.REBECCA_PURPLE
var completed_combo = false

@onready
var score_label = $HBoxContainer/menu_bar/MarginContainer/VBoxContainer/colored_container2/MarginContainer/VBoxContainer/ScoreLabel
@onready var dice_container_node = $HBoxContainer/VBoxContainer/dice_container/point
@onready
var limit_label = $HBoxContainer/VBoxContainer/dice_container/VBoxContainer/MarginContainer/LimitLabel


func lose():
	# lose :(
	if not lost:
		lost = true
		$AnimationPlayer.play("lose")


func win():
	if not won:
		won = true
		$AnimationPlayer.play("win")
		UserData.money += money_reward

		# push text to the random label

		await $AnimationPlayer.animation_finished

		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. PRIMARY
		)

		add_text_label(
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel,
			"\n- final score : " + str(UserData.current_score),
		)

		await get_tree().create_timer(0.05).timeout  # wait a bit before showing the menu
		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. SECONDARY
		)

		await get_tree().create_timer(0.6).timeout  # wait a bit before showing the menu

		var draw_limit_str = ""
		if draw_limit != -1:
			draw_limit_str = str(draw_limit - draw_used) + " left, " + str(draw_used) + " bonus"
		else:
			draw_limit_str = "infinite, 0 bonus"

		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. PRIMARY
		)

		add_text_label(
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel,
			"\n- draw limit : " + draw_limit_str,
		)
		await get_tree().create_timer(0.05).timeout  # wait a bit before showing the menu
		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. SECONDARY
		)
		await get_tree().create_timer(0.6).timeout  # wait a bit before showing the menu

		var machine_limit_str = ""
		if machine_limit != -1:
			machine_limit_str = (
				str(machine_limit - machine_used) + " left, " + str(machine_used) + " bonus"
			)
		else:
			machine_limit_str = "infinite, 0 bonus"

		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. PRIMARY
		)

		add_text_label(
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel,
			"\n- dice machine left : " + machine_limit_str,
		)

		await get_tree().create_timer(0.05).timeout  # wait a bit before showing the menu
		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. SECONDARY
		)

		await get_tree().create_timer(0.7).timeout  # wait a bit before showing the menu

		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. PRIMARY
		)

		add_text_label(
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel,
			"\n- money earned : " + str(money_reward) + " $",
		)

		await get_tree().create_timer(0.05).timeout  # wait a bit before showing the menu
		$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel.color_role = (
			$win_menu/MarginContainer/colored_container/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/RichLabel
			. ColorRole
			. SECONDARY
		)


func add_text_label(node: Label, text: String) -> void:
	# set the text
	node.text = node.text + text


func _ready() -> void:
	AudioManager.start_music()
	if not is_tutorial:
		$tutorial_anchor.queue_free()

	$HBoxContainer/menu_bar/MarginContainer/VBoxContainer/HBoxContainer/colored_container2/MarginContainer/VBoxContainer/GoalLabel.label_text = (str(
		goal
	))

	Palette.seed_color = seed_color
	Palette.assign_new_palette()
	cached_game_container_size = $HBoxContainer/VBoxContainer/game_container.size
	update_playing_pos()
	await get_tree().process_frame
	$HBoxContainer/VBoxContainer/game_container/drawing.position.y = (
		$HBoxContainer/VBoxContainer/separartor.position.y - 56 * 2 + 8
	)
	select_index(0)


func _process(_delta: float) -> void:
	score_label.label_text = str(UserData.current_score)
	update_on_resize()

	var dice_number = dice_container_node.get_child_count()

	limit_label.label_text = (str(dice_number) + "/" + str(dice_limit) + " dices")

	# if dice_number == 0 then lose

	if dice_number == 0 and not playing_move:
		lose()

	if UserData.current_score >= goal and not won:
		win()


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


func play_combo_label_anim():
	var tween = $ComboLabel.create_tween()
	tween.tween_property($ComboLabel, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(
		Tween.EASE_OUT
	)
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	var tween2 = $ComboLabel.create_tween()
	tween2.tween_property($ComboLabel, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(
		Tween.EASE_IN
	)
	await tween2.finished


func _on_dice_reached_center() -> void:
	if active_dice == null:
		return

	# roll the dice

	active_dice.roll()
	await active_dice.roll_finished

	UserData.score(active_dice.value[0])

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

	# calculate patterns if there are 3 dices in the queue
	if dice_queue.size() > 1:
		var last_three = []
		var dice_in_queue = dice_queue.size()
		if dice_in_queue >= 2:
			last_three = [
				{
					"value": dice_queue[dice_queue.size() - 3].value[0],
					"name": dice_queue[dice_queue.size() - 3].dice_name
				},
				{
					"value": dice_queue[dice_queue.size() - 2].value[0],
					"name": dice_queue[dice_queue.size() - 2].dice_name
				},
				{
					"value": dice_queue[dice_queue.size() - 1].value[0],
					"name": dice_queue[dice_queue.size() - 1].dice_name
				},
			]
		else:
			last_three = [
				{
					"value": dice_queue[dice_queue.size() - 3].value[0],
					"name": dice_queue[dice_queue.size() - 3].dice_name
				},
				{
					"value": dice_queue[dice_queue.size() - 2].value[0],
					"name": dice_queue[dice_queue.size() - 2].dice_name
				},
				{"value": 0, "name": "null", "fake": true},
			]
		var patterns_found = match_patterns(last_three)
		if patterns_found.size() > 0:
			# print every pattern found
			for pattern in patterns_found.keys():
				await pattern_found_animation()

				$BonusLabel.label_text = "x" + str(patterns_found[pattern]["mult"])
				$AnimationPlayer.play("combo_mult_text")
				await $AnimationPlayer.animation_finished
				print("pattern found : " + pattern)
				var pattern_name = patterns_found[pattern]["name"]

				# a tween to show the pattern name for 2s with modulate for fadin and fadout
				play_combo_label_anim()
				$ComboLabel.label_text = pattern_name

				if not completed_combo:
					completed_combo = true
				UserData.score(
					int(
						(
							dice_queue[dice_queue.size() - 1].value[0]
							* (patterns_found[pattern]["mult"] - 1)
						)
					)
				)
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
		# do smth when tween is finished
		tween.tween_callback(func(): old_dice_callback(i, i.get_index()))


func old_dice_callback(dice: Node2D, index) -> void:
	# if the size > 3 and it's the last one, remove it

	if dice_queue.size() > 3 and index == 0:
		dice_queue.pop_front()


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
				. tween_property(i, "scale", Vector2(1.2, 1.2), 0.055)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_OUT)
			)
		else:
			(
				tween
				. tween_property(i, "scale", Vector2(1, 1), 0.055)
				. set_trans(Tween.TRANS_QUAD)
				. set_ease(Tween.EASE_OUT)
			)
		tween.tween_property(
			i, "position", Vector2(idx * 85, cached_dice_container_height / 2), 0.055
		)


func select_index(new_index: int) -> void:
	var old_index = selected_index
	var point = $HBoxContainer/VBoxContainer/dice_container/point
	var count = point.get_child_count()

	if count == 0:
		selected_index = 0
	else:
		var wrapped = new_index % count
		if wrapped < 0:
			wrapped += count
		selected_index = wrapped

	# trigger focus() on the selected dice

	for i in point.get_children():
		if i.get_index() == selected_index:
			i.focus()

	# trigger unfocus()

	for i in point.get_children():
		if i.get_index() == old_index and i.get_index() != selected_index:
			i.unfocus()


func _input(_event: InputEvent) -> void:
	if UserData.paused:
		return

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

	if Input.is_action_just_pressed("play") and not playing_move and not is_drawing_a_dice:
		var point = $HBoxContainer/VBoxContainer/dice_container/point
		if selected_index < point.get_child_count():
			active_dice = point.get_child(selected_index)
			active_dice.unfocus()
			dice_refresh_blocked = true
			playing_move = true
			move_active_dice()

	if Input.is_action_just_pressed("draw"):
		var dice_number = $HBoxContainer/VBoxContainer/dice_container/point.get_child_count()

		if dice_limit == dice_number:
			return

		if machine_limit != -1 and (machine_used >= machine_limit):
			return

		is_drawing_a_dice = true
		# verify if we're not playing a move rn
		if playing_move:
			return

		machine_used += 1
		var newDice = UserData.get_reserved_dice()
		if newDice == null:
			return
		else:
			$HBoxContainer/menu_bar/MarginContainer/VBoxContainer/dice_machine.add_dice(newDice)

	if Input.is_action_just_pressed("remove_dice"):
		# remove the dice

		draw_limit = draw_limit - 1
		remove_dice(selected_index)


func remove_dice(index: int) -> void:
	var point = $HBoxContainer/VBoxContainer/dice_container/point
	if index < 0 or index >= point.get_child_count():
		return

	var dice = point.get_child(index)
	if dice == null:
		return

	dice.unfocus()

	dice_refresh_blocked = true

	var tween = dice.create_tween()
	(
		tween
		. tween_property(dice, "position", dice.position + Vector2(0, +150), 0.3)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)
	tween.tween_property(dice, "modulate:a", 0.0, 0.05).set_trans(Tween.TRANS_LINEAR)

	tween.tween_callback(
		func():
			dice.queue_free()

			var count = point.get_child_count()
			if count == 0:
				selected_index = 0
			else:
				selected_index = clamp(index, 0, count - 1)

			dice_refresh_blocked = false
			await get_tree().process_frame
			select_index(selected_index)
			redraw_screen()
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
		. tween_property(dice, "scale", Vector2(1.2, 1.2), 0.055)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_property(dice, "scale", Vector2(1, 1), 0.055).set_trans(Tween.TRANS_QUAD).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_callback(func(): _on_dice_added(dice))


func _on_dice_added(dice: Node2D) -> void:
	dice_refresh_blocked = false
	dice.z_index = 10

	var point = $HBoxContainer/VBoxContainer/dice_container/point
	select_index(point.get_child_count() - 1)
	redraw_screen()
	is_drawing_a_dice = false


func empty_queue():
	for i in dice_queue:
		# set a tween to move to the left and fade out after 1 second
		var tween = i.create_tween()

		(
			tween
			. tween_property(i, "position", i.position + Vector2(-1000, 0), 0.5)
			. set_trans(Tween.TRANS_QUAD)
			. set_ease(Tween.EASE_IN)
		)
		tween.tween_property(i, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func(): i.queue_free())
	dice_queue.clear()


func match_patterns(arr: Array) -> Dictionary:
	var results = {}
	for pattern in patterns:
		if pattern["check"].call(arr):
			results[pattern["name"]] = {"mult": pattern["multiplier"], "name": pattern["name"]}
	return results


func pattern_found_animation(multiplier: int = 1) -> void:
	# ge tall of th dices and put them down a little one by one, then show the multiplicator and then put them back up

	var delay = 0.0
	for i in dice_queue:
		var tween = i.create_tween()
		tween.tween_property(i, "position:y", i.position.y + 20, 0.2).set_delay(delay)
		delay += 0.1
		await tween.finished
		await get_tree().create_timer(0.2).timeout
		var tween_back = i.create_tween()
		tween_back.tween_property(i, "position:y", i.position.y - 20, 0.2)
		await tween_back.finished
