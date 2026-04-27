extends Control

# Un tableau avec les noms de votre équipe
const EQUIPE = [
	{"nom": "Raphael Letourneur", "role": "Gameplay"},
	
]

func _ready() -> void:
	for membre in EQUIPE:
		var label = Label.new()
		label.text = "%s — %s" % [membre["nom"], membre["role"]]
		$CenterContainer/VBoxContainer/VBoxContainer.add_child(label)

func _on_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/menu.tscn")
