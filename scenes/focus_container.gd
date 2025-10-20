extends VBoxContainer

var buttons: Array[Button] = []
var focused_index: int = 0

@export var active = true
@export var inactive_when_paused: bool = false


func _ready() -> void:
	for i in get_children():
		if i is MarginContainer:
			for j in i.get_children():
				if j is Button:
					_add_button(j)
		elif i is Button:
			_add_button(i)

	if buttons.size() > 0:
		focused_index = 0
		await get_tree().process_frame
		await get_tree().process_frame
		_focus_next_button()
		_focus_previous_button()


func _process(_delta: float) -> void:
	if inactive_when_paused:
		if UserData.paused == false:
			active = false
		else:
			active = true


func _add_button(btn: Button) -> void:
	buttons.append(btn)
	btn.focus_mode = Control.FOCUS_ALL


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_focus_next_button()
	elif event.is_action_pressed("ui_up"):
		_focus_previous_button()
	elif event.is_action_pressed("ui_accept") and buttons.size() > 0 and active:
		buttons[focused_index].emit_signal("pressed")


func _focus_next_button() -> void:
	if buttons.size() == 0:
		return
	focused_index = (focused_index + 1) % buttons.size()
	focus_btn(buttons[focused_index])


func _focus_previous_button() -> void:
	if buttons.size() == 0:
		return
	focused_index = (focused_index - 1 + buttons.size()) % buttons.size()
	focus_btn(buttons[focused_index])


func focus_btn(btn: Button) -> void:
	for i in range(buttons.size()):
		if buttons[i] == btn:
			btn.set_light_font_color()
			btn.focused = true
			btn.add_theme_stylebox_override("normal", buttons[i].stylebox_hover)
		else:
			buttons[i].set_dark_font_color()
			buttons[i].focused = false
			buttons[i].add_theme_stylebox_override("normal", buttons[i].stylebox_normal)


func reset() -> void:
	focused_index = 0
	if buttons.size() > 0:
		focus_btn(buttons[focused_index])
