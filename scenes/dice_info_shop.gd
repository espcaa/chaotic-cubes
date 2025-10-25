extends Control

var price: int = 0
var description: String
var lore: String
var dice_name: String
var buttons_active: bool = false

var modal_shown: bool = false


func _process(delta: float) -> void:
	%DiceNameLabel.text = dice_name
	%DiceDescLabel.text = description
	%DiceLoreLabel.text = lore

	%focus_container.active = buttons_active
	%PriceLabel.text = str(price) + "$"


func _ready() -> void:
	$modal.position.x -= 168
	$modal.size.x = 640


func show_modal():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("in")
		modal_shown = true
	else:
		await $AnimationPlayer.animation_finished
		modal_shown = true
		$AnimationPlayer.play("in")


func hide_modal():
	if not $AnimationPlayer.is_playing():
		modal_shown = false
		$AnimationPlayer.play("out")
	else:
		await $AnimationPlayer.animation_finished
		modal_shown = false
		$AnimationPlayer.play("out")


func _on_finance_button_pressed() -> void:
	get_parent().get_parent().disable_button_focus()
	show_modal()
