extends Control

@export var combo_name: String = "something"
@export var combo_mult: String = "x100??"


func _ready() -> void:
	# now animate going down with a tween

	await get_tree().process_frame

	var tween = create_tween()
	(
		tween
		. tween_property(
			$colored_container,
			"position:y",
			-(position.y - $colored_container.size.y),
			0.5,
		)
		. set_trans(Tween.TRANS_LINEAR)
		. set_ease(Tween.EASE_IN_OUT)
	)

	await tween.finished
	await get_tree().create_timer(1.5).timeout

	# now tween it to the left by size.x
	var tween2 = create_tween()
	(
		tween2
		. tween_property(
			$colored_container,
			"position:x",
			-(position.x + $colored_container.size.x),
			.3,
		)
		. set_trans(Tween.TRANS_LINEAR)
		. set_ease(Tween.EASE_IN_OUT)
	)
	await tween2.finished
	queue_free()


func _process(_delta: float) -> void:
	$colored_container/MarginContainer/container/name.text = combo_name
	$colored_container/MarginContainer/container/mult.text = combo_mult
