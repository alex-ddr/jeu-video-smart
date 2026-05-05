extends Control

func _ready() -> void:
	GameManager.load_game()
	var max_unlocked = GameManager.save_data.get("unlocked_level", 0)

	var buttons_container = $CenterContainer/VBoxContainer/HBoxContainer

	# Variable pour savoir quel index correspond à quel bouton
	var level_idx = 0
	for child in buttons_container.get_children():
		if child is Button:
			if level_idx > max_unlocked:
				child.disabled = true
			else:
				child.disabled = false
			level_idx += 1

func _on_level_pressed(index: int) -> void:
	GameManager.start_game(index)


func _on_back_pressed() -> void:
	GameManager.go_to_menu()
