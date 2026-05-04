extends Control

func _on_play_pressed() -> void:
	GameManager.start_game(0)

func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/menu/levels.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/credits/credits.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
