extends Control

var price: int = 10
var description: String
var lore: String
var dice_name: String
var buttons_active: bool = false

var modal_shown: bool = false
var active: bool = true

var active_focus_container: Control = null
var error_color: Color
var gambling_percentage: int = 0

var moving_forward := true
var speed := 2.5
var going_back_and_forth := false

var modal_mode = "normal"  # normal, gamble

var mode_to_node = {}


func _ready() -> void:
	mode_to_node = {"normal": %NormalModal, "gamble": %GamblingContainer}

	error_color = Palette.get_color("error")

	$modal.position.x -= 168
	$modal.size.x = 640

	var percentage = (UserData.money / price) * 100

	%MutableThingy.label_text = (
		"\nYou need to have "
		+ str(price)
		+ "$ to buy this dice but you only have "
		+ str(UserData.money)
		+ "$."
		+ "You have "
		+ str(percentage)
		+ "% of chance to get it if you gamble :D"
	)
	%ButtonModalContainer.disable_focus_everywhere()

	%Slider.set_instance_shader_parameter("secondary_replaced_color", error_color)


func _process(delta: float) -> void:
	gambling_percentage = %Slider.value
	%GamblingText.text = generate_gambling_string()
	%DiceNameLabel.text = dice_name
	%DiceDescLabel.text = description
	%DiceLoreLabel.text = lore
	%PriceLabel.text = str(price) + "$"
	%focus_container.active = buttons_active
	if active_focus_container != null:
		active_focus_container.active = modal_shown

	var pathfollower = %ArrowFollower
	if going_back_and_forth:
		if moving_forward:
			var new_progress_ratio = pathfollower.progress_ratio + speed * delta
			if new_progress_ratio >= 1.0:
				pathfollower.progress_ratio = 1.0
				moving_forward = false
			else:
				pathfollower.progress_ratio = new_progress_ratio
		else:
			var new_progress_ratio = pathfollower.progress_ratio - speed * delta
			if new_progress_ratio <= 0.0:
				pathfollower.progress_ratio = 0.0
				moving_forward = true
			else:
				pathfollower.progress_ratio = new_progress_ratio


func show_modal() -> void:
	if modal_shown:
		return

	%focus_container.active = false
	%ButtonModalContainer.active = false
	%SliderContainer.active = true
	active_focus_container = %SliderContainer
	buttons_active = false

	if $AnimationPlayer.is_playing():
		await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("in")
	modal_shown = true


func hide_modal() -> void:
	if not modal_shown:
		return

	if $AnimationPlayer.is_playing():
		await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("out")
	buttons_active = true
	modal_shown = false
	active_focus_container.active = false
	%ButtonModalContainer.active = true
	await $AnimationPlayer.animation_finished


func _on_finance_button_pressed() -> void:
	get_parent().get_parent().disable_button_focus()
	show_modal()


func _on_cancel_button_pressed() -> void:
	await hide_modal()
	get_parent().get_parent().enable_button_focus()


func _input(event: InputEvent) -> void:
	if (
		modal_shown
		and event.is_action_pressed("ui_cancel")
		and not $AnimationPlayer.is_playing()
		and not modal_mode == "gamble"
	):
		_on_cancel_button_pressed()


func _on_button_modal_container_reached_beginning() -> void:
	%SliderContainer.active = true
	%ButtonModalContainer.active = false
	active_focus_container = %SliderContainer
	%SliderContainer.reenable_focus()
	%ButtonModalContainer.disable_focus_everywhere()


func _on_slider_container_reached_end() -> void:
	print("hwarpiejqds?")
	%SliderContainer.active = false
	%ButtonModalContainer.active = true
	%ButtonModalContainer.reenable_focus()
	active_focus_container = %ButtonModalContainer
	%SliderContainer.disable_focus_everywhere()


func generate_gambling_string() -> String:
	var money_gambled = UserData.money * (gambling_percentage / 100.0)
	var chance = money_gambled * 100 / price

	var rounded_chance = round(chance * 100) / 100.0
	var rounded_money_gambled = round(money_gambled * 100) / 100.0
	return (
		"You are about to gamble "
		+ str(rounded_money_gambled)
		+ "$ with a "
		+ str(rounded_chance)
		+ "% chance to win the dice!"
	)


func _on_continue_button_pressed() -> void:
	var money_gambled = UserData.money * (gambling_percentage / 100.0)
	var percentage = money_gambled * 100 / price
	UserData.money -= money_gambled

	var first_point = 0.1
	if percentage > 89:
		first_point = 0.0

	var end_point = percentage / 100.0 + first_point
	if end_point > 1.0:
		end_point = 1.0

	var gradient = Gradient.new()
	gradient.colors = [
		Palette.get_color("accent"),
		Palette.get_color("accent"),
		Palette.get_color("primary"),
		Palette.get_color("primary"),
		Palette.get_color("accent"),
		Palette.get_color("accent"),
	]
	gradient.offsets = [0.0, first_point, first_point, end_point, end_point, 1.0]  # second color sharp stop  # optional, for full coverage

	var gradientx = GradientTexture2D.new()
	gradientx.gradient = gradient
	gradientx.width = 256
	%GambleTexture.texture = gradientx
	toggle_modal_mode("gamble")
	moving_forward = true
	going_back_and_forth = true
	%ArrowFollower.progress_ratio = 0.0
	var timer = Timer.new()
	timer.wait_time = 2.0 + randf_range(0.0, 1.0)
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(Callable(self, "_on_gamble_timer_timeout"))

	while going_back_and_forth:
		await get_tree().process_frame

	# now check if %ArrowFollower.progress_ratio is within the winning range
	var final_ratio = %ArrowFollower.progress_ratio
	if final_ratio >= first_point and final_ratio <= end_point:
		# win
		UserData.unlock_dice(dice_name)
		%ResultLabel.text = (
			"Congratulations! You won the '" + dice_name + "' dice!!! (keep gambling hehe)"
		)
	else:
		# lose
		%ResultLabel.text = "Seems like you lost... 99% of gamblers give up before a big win"
	await get_tree().create_timer(2.0).timeout
	hide_modal()
	await toggle_modal_mode("normal")


func _on_gamble_timer_timeout() -> void:
	going_back_and_forth = false


func toggle_modal_mode(new_mode: String) -> void:
	if modal_mode == new_mode:
		return

	var modal = %modal_marg_cont

	var close_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	close_tween.tween_property(modal, "scale:y", 0.0, 0.2)
	close_tween.parallel().tween_property(modal, "position:y", 360.0 / 2, 0.2)
	await close_tween.finished

	mode_to_node[modal_mode].hide()
	mode_to_node[modal_mode].reparent($reserve)
	modal_mode = new_mode
	mode_to_node[modal_mode].reparent(%ModalModesContainer)
	%modal_marg_cont.size.y = 360
	mode_to_node[modal_mode].show()

	var open_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	open_tween.tween_property(modal, "scale:y", 1.0, 0.2)
	open_tween.parallel().tween_property(modal, "position:y", 0.0, 0.2)
	await open_tween.finished
