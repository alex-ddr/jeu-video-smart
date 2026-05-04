extends Control

# Un tableau avec les noms de votre équipe
const EQUIPE = [
	{"nom": "Raphael Letourneur", "role": "r"},
	{"nom": "Maxence Heurtault", "role": "r"},
	{"nom": "Alexandre Didier", "role": "r"},
	{"nom": "Alois Pinto de Silva -- Winnefeld ", "role": "r"},
	{"nom": "Hugo Marin", "role": "r"},
	{"nom": "Robin Renous", "role": "r"}
]

func _ready() -> void:
	var list_container := $CenterContainer/VBoxContainer/VBoxContainer
	list_container.add_theme_constant_override("separation", 10)

	for membre in EQUIPE:
		var label := Label.new()
		label.text = "%s" % [membre["nom"]]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 30)

		list_container.add_child(label)

func _on_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/menu.tscn")
