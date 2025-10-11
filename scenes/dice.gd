extends Node2D

signal roll_finished

@export var dice_frames: SpriteFrames = load("res://assets/dice_normal.tres")
@export var faces: Array = [0, 1, 2, 3, 4, 5]

var value: Array = []
var playing = false
var dice_description: String = "[redacted]"
var dice_name: String = "[redacted description]"

var dice_tooltip_width: float = 0.0


func roll():
	pass


func _ready() -> void:
	set_dice_name()
	$colored_container/MarginContainer/text_container/title.label_text = dice_description
	$colored_container/MarginContainer/text_container/description.label_text = dice_name
	custom_ready()
	await get_tree().process_frame  # wait a frame to ensure everything is set up
	$AnimatedSprite2D.sprite_frames = dice_frames
	dice_tooltip_width = $colored_container.size.x


func focus():
	var tween = create_tween()
	tween.tween_property($colored_container, "scale", Vector2(1.0, 1.0), 0.2)
	tween.parallel().tween_property(
		$colored_container, "position", Vector2(-dice_tooltip_width / 2, -80), 0.2
	)

	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "custom_focus"))


func unfocus():
	var tween = create_tween()
	tween.tween_property($colored_container, "scale", Vector2(0.0, 0.0), 0.2)
	tween.parallel().tween_property($colored_container, "position", Vector2(0.0, -40.0), 0.2)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "custom_unfocus"))


func custom_focus():
	pass


func custom_unfocus():
	pass


func custom_ready():
	pass


func set_dice_name():
	pass

func thingy():
	get_child(2).z_index = 200
