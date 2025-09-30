extends RigidBody2D



var bounce_count: int = 0
var max_bounces: int = 3  # change as needed
var stopped: bool = false
var linear_velocity_threshold: float = 10.0  # when to consider "stopped"


func _ready():
	contact_monitor = true
	max_contacts_reported = 10


func _on_body_entered(body: Node) -> void:
	$AudioStreamPlayer.play()
	bounce_count += 1
	print("Bounce!", bounce_count)

func _integrate_forces(state) -> void:
	if stopped:
		return

	# Check if dice is nearly stopped
	if state.linear_velocity.length() < linear_velocity_threshold and bounce_count >= max_bounces:
		stopped = true
		print("Dice has stopped!")
		# You can call a function here to finalize the dice
