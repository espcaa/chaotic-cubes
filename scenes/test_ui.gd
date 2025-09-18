extends Control

func _ready() -> void:
	Palette.assign_new_palette()

	change_panel_color($HBoxContainer/primary, "primary")
	change_panel_color($HBoxContainer/background, "background")
	change_panel_color($HBoxContainer/secondary, "secondary")
	change_panel_color($HBoxContainer/accent, "accent")


func change_panel_color(panel: PanelContainer, colorString):
	if not panel:
		return

	var stylebox = panel.get_theme_stylebox("panel")
	if stylebox is StyleBoxFlat:
		var stylebox_flat: StyleBoxFlat = stylebox as StyleBoxFlat
		
		var new_color: Color = Palette.get_color(colorString)
		
		stylebox_flat.set_bg_color(new_color)
	else:
		push_warning("The panel's stylebox is not a StyleBoxFlat. Cannot change color.")
