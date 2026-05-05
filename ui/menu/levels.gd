extends Control

func _on_level_pressed(index: int) -> void:
	GameManager.start_game(index)


func _on_back_pressed() -> void:
	GameManager.go_to_menu()
