extends Control

@onready var play_button = $CenterContainer/VBoxContainer/Jouer

const MENUS = {
		"levels" : "res://ui/menu/levels.tscn",
		"credits" : "res://ui/credits/credits.tscn",
		"settings" : "res://ui/menu/settings/settings.tscn"
}
const MENU_TRANSITION_TIME = 0.5
const QUIT_TRANSITION_TIME = 1

func go_to_scene_menu(menu : String):
	await IrisWipe.close_transition(MENU_TRANSITION_TIME)
	get_tree().change_scene_to_file(MENUS[menu])
	GameManager.add_world_environment()
	await IrisWipe.open_transition(MENU_TRANSITION_TIME)

func quit_game():
	await IrisWipe.close_transition(QUIT_TRANSITION_TIME)
	get_tree().quit()


func _ready() -> void:
	play_button.grab_focus()

func _on_play_pressed() -> void:
	GameManager.start_game(0)


func _on_levels_pressed() -> void:
	go_to_scene_menu("levels")

func _on_credits_pressed() -> void:
		go_to_scene_menu("credits")

	
func _on_settings_pressed() -> void:
		go_to_scene_menu("settings")
		
func _on_quit_pressed() -> void:
	quit_game()
