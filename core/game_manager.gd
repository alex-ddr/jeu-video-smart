extends Node

const SAVE_PATH := "user://save.json"
const MAIN_MENU := "res://ui/menu/menu.tscn"
const LEVELS := [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
]

var save_data := { "level_index": 0, "checkpoint_id": 0 }

func go_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

func start_game(level_index: int = 0) -> void:
	save_data["level_index"] = level_index
	save_data["checkpoint_id"] = 0
	get_tree().change_scene_to_file(LEVELS[level_index])

func load_next_level() -> void:
	var next = save_data["level_index"] + 1
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
