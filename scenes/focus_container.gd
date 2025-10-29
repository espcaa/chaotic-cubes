extends Container

var buttons: Array[Button] = []
var focused_index: int = 0
@export var inactive_when_not_paused : bool = false

@export var active = true
@export var inactive_when_paused: bool = false
@export var horizontal: bool = false
@export var slider_only: bool = false

@export var wrap_around_top = true
@export var wrap_around_bottom = true
# emit the signals only if wrap_around of that end is false
signal reached_end
signal reached_beginning
@export var no_wrap: bool = false

var slider: HSlider


func _ready() -> void:
	for i in get_children():
		if i is MarginContainer:
			for j in i.get_children():
				if j is Button and not slider_only:
					_add_button(j)
				if j is HSlider:
					slider = j
					slider.focus_mode = Control.FOCUS_ALL
		elif i is Button:
			_add_button(i)
		elif i is HSlider:
			slider = i

	if buttons.size() > 0:
		focused_index = 0
		await get_tree().process_frame
		await get_tree().process_frame
		_focus_next_button()
		_focus_previous_button()


func _process(_delta: float) -> void:
	if inactive_when_paused:
		if UserData.paused:
			active = false
		else:
			active = true
	
	if inactive_when_not_paused:
		if UserData.paused:
			active = true
		else:
			active = false

	if not active:
		disable_focus_everywhere()
	else:
		reenable_focus()


func _add_button(btn: Button) -> void:
	buttons.append(btn)
	btn.focus_mode = Control.FOCUS_ALL


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") and active and horizontal == false and not slider_only:
		_focus_next_button()
	elif event.is_action_pressed("ui_up") and active and horizontal == false and not slider_only:
		_focus_previous_button()
	elif event.is_action_pressed("ui_right") and active and horizontal == true and not slider_only:
		_focus_next_button()
	elif event.is_action_pressed("ui_left") and active and horizontal == true and not slider_only:
		_focus_previous_button()
	elif event.is_action_pressed("ui_accept") and buttons.size() > 0 and active and not slider_only:
		buttons[focused_index].emit_signal("pressed")

	if event.is_action_pressed("ui_left") and slider_only and active:
		slider.value -= slider.step
	elif event.is_action_pressed("ui_right") and slider_only and active:
		slider.value += slider.step
	elif event.is_action_pressed("ui_up") and slider_only and active:
		reached_beginning.emit()
		print("h")
	elif event.is_action_pressed("ui_down") and slider_only and active:
		reached_end.emit()
		print("ajeipsdjq?")


func _focus_next_button() -> void:
	if buttons.size() == 0:
		return
	if focused_index + 1 >= buttons.size():
		if wrap_around_bottom:
			if not no_wrap:
				focused_index = 0
				focus_btn(buttons[focused_index])
			else:
				pass
		else:
			reached_end.emit()
	else:
		focused_index += 1
		focus_btn(buttons[focused_index])


func _focus_previous_button() -> void:
	if buttons.size() == 0:
		return
	if focused_index - 1 < 0:
		if wrap_around_top:
			if not no_wrap:
				focused_index = buttons.size() - 1
				focus_btn(buttons[focused_index])
			else:
				pass
		else:
			reached_beginning.emit()
	else:
		focused_index -= 1
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


func reenable_focus() -> void:
	if slider:
		pass
		# TODO: implement slider ofcus of some sort
	if buttons.size() > 0:
		focus_btn(buttons[focused_index])


func reset() -> void:
	focused_index = 0
	if buttons.size() > 0:
		focus_btn(buttons[focused_index])


func disable_focus_everywhere() -> void:
	if buttons.size() == 0:
		if slider:
			pass
		return
	for i in range(buttons.size()):
		buttons[i].set_dark_font_color()
		buttons[i].focused = false
		buttons[i].add_theme_stylebox_override("normal", buttons[i].stylebox_normal)
