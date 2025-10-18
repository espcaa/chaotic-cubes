extends VBoxContainer

var buttons: Array[Button] = []
var focused_index: int = 0
var manual_focus: bool = false  # flag to disable our own focus movement when user interacts


func _ready() -> void:
	for i in get_children():
		if i is MarginContainer:
			for j in i.get_children():
				if j is Button:
					_add_button(j)
		elif i is Button:
			_add_button(i)

	if buttons.size() > 0:
		buttons[0].grab_focus()


func _add_button(btn: Button) -> void:
	buttons.append(btn)
	btn.focus_mode = Control.FOCUS_ALL
	btn.connect(
		"mouse_entered", Callable(self, "_on_button_focus_entered").bind(buttons.size() - 1)
	)
	btn.connect("gui_input", Callable(self, "_on_button_gui_input"))


func _on_button_focus_entered(index: int) -> void:
	focused_index = index
	manual_focus = true  # user focused something manually
	# optional: print("Focus entered on ", buttons[index].name)


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		manual_focus = true  # user is using the mouse


func _input(event: InputEvent) -> void:
	# if user focused something manually, don't interfere
	if manual_focus:
		return

	if event.is_action_pressed("ui_down"):
		_focus_next_button()
	elif event.is_action_pressed("ui_up"):
		_focus_previous_button()
	elif event.is_action_pressed("ui_accept"):
		if focused_index != -1 and focused_index < buttons.size():
			buttons[focused_index].emit_signal("pressed")


func _focus_next_button() -> void:
	if buttons.size() == 0:
		return
	focused_index = (focused_index + 1) % buttons.size()
	buttons[focused_index].grab_focus()


func _focus_previous_button() -> void:
	if buttons.size() == 0:
		return
	focused_index = (focused_index - 1 + buttons.size()) % buttons.size()
	buttons[focused_index].grab_focus()


func reset_focus_control() -> void:
	manual_focus = false
