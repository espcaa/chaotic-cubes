extends Control

var price: int = 0
var description: String
var lore: String
var dice_name: String
var buttons_active: bool = false


func _process(delta: float) -> void:
	%DiceNameLabel.text = dice_name
	%DiceDescLabel.text = description
	%DiceLoreLabel.text = lore

	%focus_container.active = buttons_active
	%PriceLabel.text = str(price) +"$"
