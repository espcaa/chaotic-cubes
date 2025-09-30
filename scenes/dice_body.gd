extends RigidBody2D

func _ready():
	contact_monitor = true
	max_contacts_reported = 4


func _on_body_entered(body: Node) -> void:
	print("uh there?")
	$AudioStreamPlayer.play()
