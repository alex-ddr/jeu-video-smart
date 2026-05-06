extends Control

@onready var retour_button = $CenterContainer/VBoxContainer/Retour

const TEAM := [
	"Hugo MARIN",
	"Robin RENOUS",
	"Alexandre DIDIER",
	"Maxence HEURTAULT",
	"Raphaël LETOURNEUR", 
	"Alois PINTO DE SILVA -- WINNEFIELD",
]

func _ready() -> void:
	var container := $CenterContainer/VBoxContainer/VBoxContainer
	for name in TEAM:
		var label := Label.new()
		label.text = name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 30)
		container.add_child(label)
		retour_button.grab_focus()


func _on_back_pressed() -> void:
	GameManager.go_to_menu()
