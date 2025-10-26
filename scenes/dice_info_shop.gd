extends Control

var price: int = 10
var description: String
var lore: String
var dice_name: String
var buttons_active: bool = false

var modal_shown: bool = false
var active: bool = true


func _ready() -> void:
	$modal.position.x -= 168
	$modal.size.x = 640


	var percentage = (UserData.money / price) * 100

	%MutableThingy.label_text = (
		"\nYou need to have "
		+ str(price)
		+ "$ to buy this dice but you only have "
		+ str(UserData.money) + "$." + "You have " + str(percentage) + "% of chance to get it if you gamble :D"
	)

func _process(delta: float) -> void:
	%DiceNameLabel.text = dice_name
	%DiceDescLabel.text = description
	%DiceLoreLabel.text = lore
	%PriceLabel.text = str(price) + "$"
	%focus_container.active = buttons_active


func show_modal() -> void:
	if modal_shown:
		return

	%focus_container.active = false
	%ButtonModalContainer.active = true

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

	modal_shown = false
	%focus_container.active = false
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
