extends Control

func _on_play_pressed() -> void:
	GameManager.start_game(0)


func _on_levels_pressed() -> void:
	await IrisWipe.close_transition(0.2)
	get_tree().change_scene_to_file("res://ui/menu/levels.tscn")
	await IrisWipe.open_transition(0.2)

func _on_credits_pressed() -> void:
	await IrisWipe.close_transition(0.2)
	get_tree().change_scene_to_file("res://ui/credits/credits.tscn")
	await IrisWipe.open_transition(0.2)


func _on_quit_pressed() -> void:
	await IrisWipe.close_transition(0.2)
	get_tree().quit()
	await IrisWipe.open_transition(0.2)
