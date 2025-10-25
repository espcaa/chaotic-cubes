extends Control


func focus_buttons():
	%FocusContainer.active = true


func _on_continue_button_pressed() -> void:
	get_parent().finish_winning()
