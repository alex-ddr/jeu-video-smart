extends Control

@onready var play_button = $CenterContainer/VBoxContainer/Jouer

func _ready() -> void:
	play_button.grab_focus()

func _on_play_pressed() -> void:
	GameManager.start_game(0)


func _on_levels_pressed() -> void:
	await IrisWipe.close_transition(0.5)
	get_tree().change_scene_to_file("res://ui/menu/levels.tscn")
	await IrisWipe.open_transition(0.5)

func _on_credits_pressed() -> void:
	await IrisWipe.close_transition(0.5)
	get_tree().change_scene_to_file("res://ui/credits/credits.tscn")
	await IrisWipe.open_transition(0.5)


func _on_quit_pressed() -> void:
	await IrisWipe.close_transition(0.5)
	get_tree().quit()
	await IrisWipe.open_transition(0.5)
