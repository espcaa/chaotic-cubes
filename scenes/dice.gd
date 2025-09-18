extends Node2D

var faces = ["1", "2", "3", "4", "5", "6"]

signal roll_finished

var timer: Timer


func roll():
	# start a 2s timer to stop the animation
	timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	# cycle through all of the animations for 2s and then stop on a random one
	while timer:
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.play(faces[randi() % faces.size()])


func _on_timer_timeout():
	timer.queue_free()
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = randi() % faces.size()
	emit_signal("roll_finished", $AnimatedSprite2D.frame + 1)  # +1 to convert from 0-5 to 1-6
