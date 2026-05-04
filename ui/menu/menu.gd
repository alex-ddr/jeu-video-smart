extends Control

const LEVEL_SELECT_SCENE = preload("res://ui/Levels/levels.tscn")
const CREDITS_SCENE = preload("res://ui/credits/crédits.tscn")
const FIRST_LEVEL = preload("res://levels/Level_01.tscn")

func _on_jouer_pressed() -> void:
	get_tree().change_scene_to_packed(FIRST_LEVEL)

func _on_niveaux_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL_SELECT_SCENE)

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(CREDITS_SCENE)

func _on_quitter_pressed() -> void:
	get_tree().quit()
