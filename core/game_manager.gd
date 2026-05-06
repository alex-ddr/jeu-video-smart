extends Node

const SAVE_PATH := "user://save.json"
const MAIN_MENU := "res://ui/menu/menu.tscn"
const LEVELS := [
	"res://levels/1.1_level.tscn",
	"res://levels/1.2_level.tscn",
	"res://levels/1.3_level.tscn",
	"res://levels/level_grass_1.tscn",
	"res://levels/level_snow_1.tscn",
	"res://levels/level_desert_1.tscn",
	"res://levels/level_space_1.tscn",
]

var save_data := {"unlocked_level" : 0}
var level_index : int = 0

func _ready() -> void:
	level_index = 0
	load_game()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen_toggle"):
		fullscreen_toggle()


func go_to_menu() -> void:
	await IrisWipe.close_transition(0.2)
	get_tree().change_scene_to_file(MAIN_MENU)
	await IrisWipe.open_transition(0.2)


func start_game(level_index_new: int = level_index) -> void:
	level_index = level_index_new
	var error :Error = get_tree().change_scene_to_file(LEVELS[level_index])
	if (error != OK):
		print("erreur au chargement du niveau d'index " + str(level_index))
	await IrisWipe.open_transition()

	
func load_next_level() -> void:
	await IrisWipe.close_transition()
	var next = level_index + 1
	print("unlocked_level :",save_data.get("unlocked_level", 0))
	if next > save_data.get("unlocked_level", 0):
		save_data["unlocked_level"] = next
		save_game() # On sauvegarde la progression sur le disque dur
	if next >= LEVELS.size():
		go_to_menu()
		return
	start_game(next)

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var result = JSON.parse_string(file.get_as_text())
	file.close()
	if result is Dictionary:
		save_data = result
		
func fullscreen_toggle() -> void:
	if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
