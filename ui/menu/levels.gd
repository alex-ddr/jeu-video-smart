extends Control

@onready var level1_button = $CenterContainer/VBoxContainer/HFlowContainer/level_1

func _ready() -> void:
	GameManager.load_game()
	var max_unlocked = GameManager.save_data.get("unlocked_level", 0)
	level1_button.grab_focus()

	var buttons_container = $CenterContainer/VBoxContainer/HFlowContainer

	for child in buttons_container.get_children():
		if child is Button:
			var level_num = child.name.lstrip("level_").to_int()
			child.disabled = level_num - 1 > max_unlocked

func _on_level_pressed(index: int) -> void:
	GameManager.start_game(index)

func _on_back_pressed() -> void:
	GameManager.go_to_menu()
