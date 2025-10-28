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


func _ready() -> void:
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
	if modal_shown and event.is_action_pressed("ui_cancel") and not $AnimationPlayer.is_playing():
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
