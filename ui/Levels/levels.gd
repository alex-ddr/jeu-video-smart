extends Control

# Ajouter les niveaux ici au fur et à mesure
const LEVELS = [
	preload("res://levels/Level_01.tscn"),
]

func _on_niveau_pressed(index: int) -> void:
	get_tree().change_scene_to_packed(LEVELS[index])

func _on_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/menu.tscn")
