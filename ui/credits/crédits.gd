extends Control

# Un tableau avec les noms de votre équipe
const EQUIPE = [
	{"nom": "Raphael Letourneur", "role": "r"},
	{"nom": "Maxence Heurtault", "role": "r"},
	{"nom": "Alexandre Didier", "role": "r"},
	{"nom": "Alois Pinto", "role": "r"},
	{"nom": "Hugo Marin", "role": "r"},
	{"nom": "Robin Renous", "role": "r"}
]

func _ready() -> void:
	for membre in EQUIPE:
		var label = Label.new()
		label.text = "%s" % [membre["nom"]]
		$CenterContainer/VBoxContainer/VBoxContainer.add_child(label)

func _on_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/menu.tscn")
