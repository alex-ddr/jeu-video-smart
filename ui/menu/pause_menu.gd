extends ColorRect

func _ready() -> void:
	# Menu caché dès le début
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("echap"):
		toggle_pause()

func _on_button_resume_pressed() -> void:
	toggle_pause()

# Si c'était en pause -> cache et arrête la pause
func toggle_pause() -> void:
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	
func _on_button_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.start_game()

func _on_button_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.go_to_menu()
